'use strict';

const rateLimit = require('express-rate-limit');
const { config } = require('../config');

const json429 = (_req, res) =>
    res.status(429).json({ error: 'Слишком много запросов, попробуйте позже' });

const generalLimiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.max,
    standardHeaders: true,
    legacyHeaders: false,
    handler: json429,
});

const writeLimiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.writeMax,
    standardHeaders: true,
    legacyHeaders: false,
    handler: json429,
});

module.exports = { generalLimiter, writeLimiter };
