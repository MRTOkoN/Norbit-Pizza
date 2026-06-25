'use strict';

const crypto = require('node:crypto');
const { config } = require('../config');
const { logger } = require('../logger');

let warned = false;

function safeEqual(a, b) {
    const ba = Buffer.from(String(a));
    const bb = Buffer.from(String(b));
    if (ba.length !== bb.length) return false;
    return crypto.timingSafeEqual(ba, bb);
}

function adminAuth(req, res, next) {
    if (!config.adminApiKey) {
        if (!warned) {
            warned = true;
            logger.warn('Security: ADMIN_API_KEY not set — mutating endpoints are PUBLIC. Set it to lock them down.');
        }
        return next();
    }

    const headerKey = req.get('x-api-key');
    const bearer = (req.get('authorization') || '').replace(/^Bearer\s+/i, '');
    const provided = headerKey || bearer;

    if (provided && safeEqual(provided, config.adminApiKey)) {
        return next();
    }
    return res.status(401).json({ error: 'Требуется авторизация' });
}

module.exports = { adminAuth };
