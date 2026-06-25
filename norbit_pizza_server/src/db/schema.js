'use strict';

const { pool } = require('./pool');
const { config } = require('../config');
const { logger } = require('../logger');

const CREATE_IMAGES = `
    CREATE TABLE IF NOT EXISTS images (
        id INT AUTO_INCREMENT PRIMARY KEY,
        filename VARCHAR(255) NOT NULL,
        mime_type VARCHAR(100),
        image_data LONGBLOB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )`;

const CREATE_PRODUCTS = `
    CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        description TEXT,
        image_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL
    )`;

const CREATE_ORDERS = `
    CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        customer_name VARCHAR(255),
        phone VARCHAR(50),
        address TEXT,
        items LONGTEXT,
        total DECIMAL(10,2) NOT NULL,
        order_number VARCHAR(8) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_order_number (order_number)
    )`;

async function ensureOrderNumber(conn) {
    const [[col]] = await conn.query(
        `SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_number'`,
        [config.db.name]
    );
    if (col.cnt === 0) {
        await conn.query("ALTER TABLE orders ADD COLUMN order_number VARCHAR(8) NOT NULL");
    }

    const [[idx]] = await conn.query(
        `SELECT COUNT(*) AS cnt FROM information_schema.STATISTICS
         WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'orders' AND INDEX_NAME = 'unique_order_number'`,
        [config.db.name]
    );
    if (idx.cnt === 0) {
        await conn.query('ALTER TABLE orders ADD UNIQUE KEY unique_order_number (order_number)');
    }
}

async function initSchema() {
    const conn = await pool.getConnection();
    try {
        await conn.query(CREATE_IMAGES);
        await conn.query(CREATE_PRODUCTS);
        await conn.query(CREATE_ORDERS);
        try {
            await ensureOrderNumber(conn);
        } catch (err) {
            logger.warn('Could not ensure order_number column/index:', err.message || err);
        }
        logger.info('DB: schema ready');
    } finally {
        conn.release();
    }
}

module.exports = { initSchema };
