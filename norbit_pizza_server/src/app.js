'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');

const { config } = require('./config');
const { logger } = require('./logger');
const { generalLimiter } = require('./middleware/rateLimiters');
const { notFound } = require('./middleware/notFound');
const { errorHandler } = require('./middleware/errorHandler');
const routes = require('./routes');

function createApp() {
    const app = express();

    app.disable('x-powered-by');
    app.set('trust proxy', config.trustProxy);

    app.use(
        helmet({
            crossOriginResourcePolicy: { policy: 'cross-origin' },
        })
    );

    app.use(cors({ origin: config.cors.origin }));

    if (!config.isTest) {
        app.use(
            morgan(config.isProduction ? 'combined' : 'dev', {
                stream: { write: (line) => logger.info(line.trim()) },
            })
        );
    }

    app.use(express.json({ limit: config.jsonLimit }));
    app.use(generalLimiter);

    app.use('/', routes);

    app.use(notFound);
    app.use(errorHandler);

    return app;
}

module.exports = { createApp };
