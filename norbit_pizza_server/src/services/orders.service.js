'use strict';

const { pool } = require('../db/pool');
const { logger } = require('../logger');
const { generateOrderNumber } = require('../utils/orderNumber');

const MAX_ORDER_NUMBER_ATTEMPTS = 8;
const RETRY_WARN_THRESHOLD = 4;

async function create({ customer_name, phone, address, items, total }) {
    const itemsJson = JSON.stringify(items);
    const conn = await pool.getConnection();
    try {
        for (let attempt = 0; attempt < MAX_ORDER_NUMBER_ATTEMPTS; attempt += 1) {
            const orderNumber = generateOrderNumber();
            try {
                const [result] = await conn.query(
                    'INSERT INTO orders (customer_name, phone, address, items, total, order_number) VALUES (?, ?, ?, ?, ?, ?)',
                    [customer_name, phone, address, itemsJson, total, orderNumber]
                );
                if (attempt + 1 >= RETRY_WARN_THRESHOLD) {
                    logger.warn(`Order number allocated after ${attempt + 1} attempts — order_number keyspace is filling up`);
                }
                return { id: result.insertId, orderNumber };
            } catch (err) {
                if (err && err.code === 'ER_DUP_ENTRY') continue;
                throw err;
            }
        }
        logger.error(`Order number allocation exhausted after ${MAX_ORDER_NUMBER_ATTEMPTS} attempts — consider widening the order_number keyspace`);
        return null;
    } finally {
        conn.release();
    }
}

module.exports = { create };
