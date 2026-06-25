'use strict';

const mysql = require('mysql2/promise');
const { config } = require('../config');

const pool = mysql.createPool({
    host: config.db.host,
    user: config.db.user,
    password: config.db.password,
    database: config.db.name,
    waitForConnections: true,
    connectionLimit: config.db.connectionLimit,
    queueLimit: 0,
    namedPlaceholders: false,
});

async function ping() {
    const conn = await pool.getConnection();
    try {
        await conn.query('SELECT 1');
        return true;
    } finally {
        conn.release();
    }
}

module.exports = { pool, ping };
