'use strict';

const express = require('express');
const multer = require('multer');
const { config } = require('../config');
const { asyncHandler } = require('../middleware/asyncHandler');
const { writeLimiter } = require('../middleware/rateLimiters');
const { adminAuth } = require('../middleware/adminAuth');
const { validate } = require('../validation/validate');
const { idParam } = require('../validation/schemas');
const ctrl = require('../controllers/images.controller');

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: config.upload.maxBytes, files: 1 },
});

const router = express.Router();

router.post('/upload', writeLimiter, adminAuth, upload.single('image'), asyncHandler(ctrl.uploadImage));

router.get('/:id', validate({ params: idParam }), asyncHandler(ctrl.getImage));

router.delete('/:id', writeLimiter, adminAuth, validate({ params: idParam }), asyncHandler(ctrl.deleteImage));

module.exports = router;
