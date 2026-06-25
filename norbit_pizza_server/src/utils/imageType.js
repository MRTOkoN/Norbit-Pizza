'use strict';

const ALLOWED_MIME_TYPES = Object.freeze(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);

function sniffMimeType(buffer) {
    if (!Buffer.isBuffer(buffer) || buffer.length < 12) return null;

    if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
        return 'image/jpeg';
    }
    if (
        buffer[0] === 0x89 && buffer[1] === 0x50 && buffer[2] === 0x4e && buffer[3] === 0x47 &&
        buffer[4] === 0x0d && buffer[5] === 0x0a && buffer[6] === 0x1a && buffer[7] === 0x0a
    ) {
        return 'image/png';
    }
    if (buffer.toString('ascii', 0, 6) === 'GIF87a' || buffer.toString('ascii', 0, 6) === 'GIF89a') {
        return 'image/gif';
    }
    if (buffer.toString('ascii', 0, 4) === 'RIFF' && buffer.toString('ascii', 8, 12) === 'WEBP') {
        return 'image/webp';
    }
    return null;
}

function isAllowedMimeType(mime) {
    return ALLOWED_MIME_TYPES.includes(mime);
}

function safeContentType(storedMime) {
    if (storedMime === 'image/jpg') return 'image/jpeg';
    return isAllowedMimeType(storedMime) ? storedMime : 'application/octet-stream';
}

module.exports = {
    ALLOWED_MIME_TYPES,
    sniffMimeType,
    isAllowedMimeType,
    safeContentType,
};
