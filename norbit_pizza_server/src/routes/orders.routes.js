'use strict';

const express = require('express');
const { asyncHandler } = require('../middleware/asyncHandler');
const { writeLimiter } = require('../middleware/rateLimiters');
const { validate } = require('../validation/validate');
const { orderBody } = require('../validation/schemas');
const ctrl = require('../controllers/orders.controller');

const router = express.Router();

router.post('/', writeLimiter, validate({ body: orderBody }), asyncHandler(ctrl.createOrder));

module.exports = router;
