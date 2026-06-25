'use strict';

const imagesService = require('../services/images.service');
const { sniffMimeType, isAllowedMimeType, safeContentType, ALLOWED_MIME_TYPES } = require('../utils/imageType');

function sanitizeFilename(name) {
    return String(name || 'image').replace(/[^\w.\- ]+/g, '_').slice(0, 120);
}

async function uploadImage(req, res) {
    if (!req.file) {
        return res.status(400).json({ error: 'Файл не загружен' });
    }

    const detected = sniffMimeType(req.file.buffer);
    if (!detected || !isAllowedMimeType(detected)) {
        return res.status(400).json({
            error: `Недопустимый тип файла. Разрешены: ${ALLOWED_MIME_TYPES.join(', ')}`,
        });
    }

    const id = await imagesService.create({
        filename: req.file.originalname,
        mimeType: detected,
        buffer: req.file.buffer,
    });
    return res.status(201).json({ id, message: 'Изображение загружено' });
}

async function getImage(req, res) {
    const image = await imagesService.getById(req.valid.params.id);
    if (!image) {
        return res.status(404).json({ error: 'Изображение не найдено' });
    }

    res.setHeader('Content-Type', safeContentType(image.mime_type));
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Content-Disposition', `inline; filename="${sanitizeFilename(image.filename)}"`);
    res.setHeader('Content-Security-Policy', "default-src 'none'; sandbox");
    res.setHeader('Cache-Control', 'public, max-age=86400');
    return res.send(image.image_data);
}

async function deleteImage(req, res) {
    const removed = await imagesService.remove(req.valid.params.id);
    if (!removed) {
        return res.status(404).json({ error: 'Изображение не найдено' });
    }
    return res.json({ message: 'Изображение удалено' });
}

module.exports = { uploadImage, getImage, deleteImage };
