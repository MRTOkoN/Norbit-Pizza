'use strict';

const dotenv = require('dotenv');

dotenv.config();

function intEnv(name, fallback) {
    const raw = process.env[name];
    if (raw === undefined || raw === '') return fallback;
    const parsed = Number.parseInt(raw, 10);
    return Number.isNaN(parsed) ? fallback : parsed;
}

function boolEnv(name, fallback) {
    const raw = process.env[name];
    if (raw === undefined || raw === '') return fallback;
    return ['1', 'true', 'yes', 'on'].includes(raw.trim().toLowerCase());
}

const env = process.env.NODE_ENV || 'development';

function parseCorsOrigin() {
    const raw = (process.env.CORS_ORIGIN || '*').trim();
    if (raw === '*' || raw === '') return '*';
    return raw.split(',').map((o) => o.trim()).filter(Boolean);
}

function parseTrustProxy() {
    const raw = (process.env.TRUST_PROXY || '').trim();
    if (raw === '' || raw === '0' || raw.toLowerCase() === 'false') return false;
    if (raw.toLowerCase() === 'true') return true;
    const n = Number.parseInt(raw, 10);
    if (!Number.isNaN(n) && String(n) === raw) return n;
    return raw;
}

const config = Object.freeze({
    env,
    isProduction: env === 'production',
    isDev: env === 'development',
    isTest: env === 'test',
    port: intEnv('PORT', 3000),
    trustProxy: parseTrustProxy(),

    db: Object.freeze({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        name: process.env.DB_NAME || 'norbit_pizza',
        connectionLimit: intEnv('DB_CONNECTION_LIMIT', 10),
    }),

    redis: Object.freeze({
        url: process.env.REDIS_URL || '',
        enabled: boolEnv('CACHE_ENABLED', true) && Boolean(process.env.REDIS_URL),
        ttlSeconds: intEnv('CACHE_TTL_SECONDS', 300),
        prefix: process.env.CACHE_PREFIX || 'norbit',
    }),

    cors: Object.freeze({
        origin: parseCorsOrigin(),
    }),

    upload: Object.freeze({
        maxBytes: intEnv('MAX_UPLOAD_BYTES', 5 * 1024 * 1024),
    }),

    rateLimit: Object.freeze({
        windowMs: intEnv('RATE_LIMIT_WINDOW_MS', 60 * 1000),
        max: intEnv('RATE_LIMIT_MAX', 300),
        writeMax: intEnv('RATE_LIMIT_WRITE_MAX', 30),
    }),

    adminApiKey: process.env.ADMIN_API_KEY || '',

    jsonLimit: process.env.JSON_BODY_LIMIT || '1mb',
});

module.exports = { config };
