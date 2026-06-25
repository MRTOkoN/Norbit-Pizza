'use strict';

const { config } = require('./config');

function emit(stream, level, args) {
    if (config.isTest) return;
    const ts = new Date().toISOString();
    stream(`[${ts}] ${level}:`, ...args);
}

const logger = {
    info: (...args) => emit(console.log, 'INFO', args),
    warn: (...args) => emit(console.warn, 'WARN', args),
    error: (...args) => emit(console.error, 'ERROR', args),
    debug: (...args) => {
        if (config.isProduction) return;
        emit(console.log, 'DEBUG', args);
    },
};

module.exports = { logger };
