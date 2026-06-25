'use strict';

const { config } = require('./src/config');
const { logger } = require('./src/logger');
const { createApp } = require('./src/app');
const { initSchema } = require('./src/db/schema');
const { pool } = require('./src/db/pool');
const cache = require('./src/cache/redis');
const productsService = require('./src/services/products.service');

const FORCE_EXIT_MS = 10_000;

async function bootstrap() {
    await initSchema();
    await cache.connect();
    await cache.warmProducts(() => productsService.listFromDb());

    const app = createApp();
    const server = app.listen(config.port, () => {
        logger.info(`Server running on http://localhost:${config.port} (env: ${config.env})`);
    });

    let shuttingDown = false;
    async function shutdown(signal) {
        if (shuttingDown) return;
        shuttingDown = true;
        logger.info(`Received ${signal}, shutting down gracefully...`);

        const forceExit = setTimeout(() => {
            logger.error('Forced shutdown after timeout');
            process.exit(1);
        }, FORCE_EXIT_MS);
        forceExit.unref();

        server.close(async () => {
            await Promise.allSettled([pool.end(), cache.quit()]);
            logger.info('Shutdown complete');
            process.exit(0);
        });

        if (typeof server.closeIdleConnections === 'function') {
            server.closeIdleConnections();
        }
    }

    for (const signal of ['SIGINT', 'SIGTERM']) {
        process.on(signal, () => shutdown(signal));
    }
}

bootstrap().catch((err) => {
    logger.error('Fatal startup error:', err);
    process.exit(1);
});
