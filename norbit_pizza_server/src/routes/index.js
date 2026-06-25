'use strict';

const express = require('express');
const { asyncHandler } = require('../middleware/asyncHandler');
const { ping: dbPing } = require('../db/pool');
const cache = require('../cache/redis');
const imageRoutes = require('./images.routes');
const productRoutes = require('./products.routes');
const orderRoutes = require('./orders.routes');

const router = express.Router();

router.get(
    '/health',
    asyncHandler(async (_req, res) => {
        const [dbOk, redisOk] = await Promise.all([
            dbPing().then(() => true).catch(() => false),
            cache.ping(),
        ]);
        const cacheStatus = cache.isReady() ? (redisOk ? 'up' : 'down') : 'disabled';
        res.status(dbOk ? 200 : 503).json({
            status: dbOk ? 'ok' : 'degraded',
            db: dbOk,
            cache: cacheStatus,
            uptime: Math.round(process.uptime()),
        });
    })
);

router.use('/images', imageRoutes);
router.use('/products', productRoutes);
router.use('/orders', orderRoutes);

module.exports = router;
