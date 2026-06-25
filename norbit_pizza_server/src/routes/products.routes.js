'use strict';

const express = require('express');
const { asyncHandler } = require('../middleware/asyncHandler');
const { writeLimiter } = require('../middleware/rateLimiters');
const { adminAuth } = require('../middleware/adminAuth');
const { validate } = require('../validation/validate');
const { idParam, productBody } = require('../validation/schemas');
const ctrl = require('../controllers/products.controller');

const router = express.Router();

router.get('/', asyncHandler(ctrl.listProducts));

router.post('/', writeLimiter, adminAuth, validate({ body: productBody }), asyncHandler(ctrl.createProduct));

router.put('/:id', writeLimiter, adminAuth, validate({ params: idParam, body: productBody }), asyncHandler(ctrl.updateProduct));

router.delete('/:id', writeLimiter, adminAuth, validate({ params: idParam }), asyncHandler(ctrl.deleteProduct));

module.exports = router;
