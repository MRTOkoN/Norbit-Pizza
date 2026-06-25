'use strict';

const { pool } = require('../db/pool');
const cache = require('../cache/redis');

async function create({ filename, mimeType, buffer }) {
    const [result] = await pool.query(
        'INSERT INTO images (filename, mime_type, image_data) VALUES (?, ?, ?)',
        [filename, mimeType, buffer]
    );
    return result.insertId;
}

async function getById(id) {
    const [rows] = await pool.query(
        'SELECT id, filename, mime_type, image_data FROM images WHERE id = ?',
        [id]
    );
    return rows[0] || null;
}

async function remove(id) {
    const [result] = await pool.query('DELETE FROM images WHERE id = ?', [id]);
    if (result.affectedRows > 0) {
        await cache.invalidateProducts();
        return true;
    }
    return false;
}

module.exports = { create, getById, remove };
