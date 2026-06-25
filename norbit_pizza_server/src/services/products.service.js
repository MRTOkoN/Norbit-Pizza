'use strict';

const { pool } = require('../db/pool');
const cache = require('../cache/redis');

const LIST_SQL = `SELECT p.id, p.name, p.price, p.description, p.created_at, i.id AS image_id, i.filename, i.mime_type
     FROM products p
     LEFT JOIN images i ON p.image_id = i.id
     ORDER BY p.created_at DESC`;

function badImageRef() {
    const err = new Error('Изображение не найдено');
    err.status = 400;
    err.expose = true;
    return err;
}

function rethrow(err) {
    if (err && (err.code === 'ER_NO_REFERENCED_ROW_2' || err.code === 'ER_NO_REFERENCED_ROW')) {
        throw badImageRef();
    }
    throw err;
}

async function listFromDb() {
    const [rows] = await pool.query(LIST_SQL);
    return rows;
}

async function list() {
    const cached = await cache.getProducts();
    if (cached) return cached;

    const rows = await listFromDb();
    await cache.setProducts(rows);
    return rows;
}

async function create({ name, price, description, image_id }) {
    let result;
    try {
        [result] = await pool.query(
            'INSERT INTO products (name, price, description, image_id) VALUES (?, ?, ?, ?)',
            [name, price, description, image_id]
        );
    } catch (err) {
        rethrow(err);
    }
    await cache.invalidateProducts();
    return result.insertId;
}

async function update(id, { name, price, description, image_id }) {
    let result;
    try {
        [result] = await pool.query(
            'UPDATE products SET name = ?, price = ?, description = ?, image_id = ? WHERE id = ?',
            [name, price, description, image_id, id]
        );
    } catch (err) {
        rethrow(err);
    }
    if (result.affectedRows > 0) {
        await cache.invalidateProducts();
        return true;
    }
    return false;
}

async function remove(id) {
    const [result] = await pool.query('DELETE FROM products WHERE id = ?', [id]);
    if (result.affectedRows > 0) {
        await cache.invalidateProducts();
        return true;
    }
    return false;
}

module.exports = { list, listFromDb, create, update, remove };
