'use strict';

const multer = require('multer');
const { logger } = require('../logger');
const { config } = require('../config');

function errorHandler(err, req, res, next) {
    if (err instanceof multer.MulterError) {
        const status = err.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
        const message =
            err.code === 'LIMIT_FILE_SIZE'
                ? `Файл слишком большой (макс. ${Math.round(config.upload.maxBytes / 1024 / 1024)} МБ)`
                : 'Ошибка загрузки файла';
        return res.status(status).json({ error: message });
    }

    const status = err.status || err.statusCode || 500;

    if (status >= 500) {
        logger.error(req.method, req.originalUrl, '-', err.stack || err);
        const message = config.isDev ? err.message || 'Internal Server Error' : 'Внутренняя ошибка сервера';
        return res.status(status).json({ error: message });
    }

    const message = err.expose ? err.message || 'Некорректный запрос' : 'Некорректный запрос';
    return res.status(status).json({ error: message });
}

module.exports = { errorHandler };
