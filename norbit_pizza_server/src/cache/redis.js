'use strict';

const Redis = require('ioredis');
const { config } = require('../config');
const { logger } = require('../logger');

const PRODUCTS_KEY = `${config.redis.prefix}:products:all`;

let client = null;
let ready = false;
let connectedOnce = false;

async function connect() {
    if (!config.redis.enabled) {
        logger.info('Cache: disabled (no REDIS_URL or CACHE_ENABLED=false) — serving straight from DB');
        return false;
    }

    client = new Redis(config.redis.url, {
        lazyConnect: true,
        maxRetriesPerRequest: 2,
        enableOfflineQueue: false,
        retryStrategy: (times) => Math.min(times * 200, 2000),
    });

    client.on('error', (err) => {
        if (ready) logger.warn('Cache: redis error —', err.message || err);
        ready = false;
    });
    client.on('ready', () => {
        ready = true;
        if (connectedOnce) {
            client.del(PRODUCTS_KEY).catch(() => {});
            logger.info('Cache: reconnected to Redis (product cache cleared)');
        } else {
            connectedOnce = true;
            logger.info('Cache: connected to Redis');
        }
    });
    client.on('end', () => { ready = false; });

    try {
        await client.connect();
        ready = true;
        return true;
    } catch (err) {
        logger.warn('Cache: initial Redis connection failed — continuing without cache:', err.message || err);
        return false;
    }
}

function isReady() {
    return Boolean(client) && ready;
}

async function getProducts() {
    if (!isReady()) return null;
    try {
        const raw = await client.get(PRODUCTS_KEY);
        return raw ? JSON.parse(raw) : null;
    } catch (err) {
        logger.warn('Cache: getProducts failed —', err.message || err);
        return null;
    }
}

async function setProducts(products) {
    if (!isReady()) return;
    try {
        await client.set(PRODUCTS_KEY, JSON.stringify(products), 'EX', config.redis.ttlSeconds);
    } catch (err) {
        logger.warn('Cache: setProducts failed —', err.message || err);
    }
}

async function invalidateProducts() {
    if (!isReady()) return;
    try {
        await client.del(PRODUCTS_KEY);
    } catch (err) {
        logger.warn('Cache: invalidateProducts failed —', err.message || err);
    }
}

async function warmProducts(loader) {
    if (!isReady()) return;
    try {
        const products = await loader();
        await setProducts(products);
        logger.info(`Cache: warmed ${products.length} products into Redis`);
    } catch (err) {
        logger.warn('Cache: warmProducts failed —', err.message || err);
    }
}

async function ping() {
    if (!isReady()) return false;
    try {
        const res = await client.ping();
        return res === 'PONG';
    } catch {
        return false;
    }
}

async function quit() {
    if (!client) return;
    try {
        await client.quit();
    } catch {
        client.disconnect();
    } finally {
        client = null;
        ready = false;
    }
}

module.exports = {
    connect,
    isReady,
    getProducts,
    setProducts,
    invalidateProducts,
    warmProducts,
    ping,
    quit,
};
