const express = require('express');
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const multer = require('multer');
const morgan = require('morgan');
const helmet = require('helmet');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'norbit_pizza',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
});

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

async function initDb() {
    const createImagesTable = `
        CREATE TABLE IF NOT EXISTS images (
            id INT AUTO_INCREMENT PRIMARY KEY,
            filename VARCHAR(255) NOT NULL,
            mime_type VARCHAR(100),
            image_data LONGBLOB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )`;

    const createProductsTable = `
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            description TEXT,
            image_id INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL
        )`;

    const conn = await pool.getConnection();
    try {
        await conn.query(createImagesTable);
        await conn.query(createProductsTable);
        console.log('DB: Tables ready');
    } finally {
        conn.release();
    }
}

initDb().catch(err => {
    console.error('DB init error:', err);
    process.exit(1);
});

// Centralized error handler helper
function handleError(res, err) {
    console.error(err);
    return res.status(500).json({ error: err.message || 'Internal Server Error' });
}

// Upload image and store blob in DB
app.post('/images/upload', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'Файл не загружен' });

        const { originalname, mimetype, buffer } = req.file;
        const conn = await pool.getConnection();
        try {
            const [result] = await conn.query(
                'INSERT INTO images (filename, mime_type, image_data) VALUES (?, ?, ?)',
                [originalname, mimetype, buffer]
            );
            res.status(201).json({ id: result.insertId, message: 'Изображение загружено' });
        } finally {
            conn.release();
        }
    } catch (err) {
        return handleError(res, err);
    }
});

// Serve image blob
app.get('/images/:id', async (req, res) => {
    const imageId = req.params.id;
    try {
        const [rows] = await pool.query('SELECT id, filename, mime_type, image_data FROM images WHERE id = ?', [imageId]);
        if (rows.length === 0) return res.status(404).json({ error: 'Изображение не найдено' });
        const image = rows[0];
        res.setHeader('Content-Type', image.mime_type);
        res.send(image.image_data);
    } catch (err) {
        return handleError(res, err);
    }
});

// Delete image
app.delete('/images/:id', async (req, res) => {
    const imageId = req.params.id;
    try {
        const [result] = await pool.query('DELETE FROM images WHERE id = ?', [imageId]);
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Изображение не найдено' });
        res.json({ message: 'Изображение удалено' });
    } catch (err) {
        return handleError(res, err);
    }
});

// Create product
app.post('/products', async (req, res) => {
    try {
        const { name, price, description = null, image_id = null } = req.body;
        if (!name || price == null) return res.status(400).json({ error: 'Название и цена обязательны' });
        const parsedPrice = Number(price);
        if (Number.isNaN(parsedPrice)) return res.status(400).json({ error: 'Цена должна быть числом' });

        const [result] = await pool.query(
            'INSERT INTO products (name, price, description, image_id) VALUES (?, ?, ?, ?)',
            [name, parsedPrice, description, image_id]
        );
        res.status(201).json({ id: result.insertId, message: 'Товар успешно добавлен', product: { id: result.insertId, name, price: parsedPrice, description, image_id } });
    } catch (err) {
        return handleError(res, err);
    }
});

// List all products (with image metadata)
app.get('/products', async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT p.id, p.name, p.price, p.description, p.created_at, i.id AS image_id, i.filename, i.mime_type
             FROM products p
             LEFT JOIN images i ON p.image_id = i.id
             ORDER BY p.created_at DESC`
        );
        res.json(rows);
    } catch (err) {
        return handleError(res, err);
    }
});

// Delete product
app.delete('/products/:id', async (req, res) => {
    const productId = req.params.id;
    try {
        const [result] = await pool.query('DELETE FROM products WHERE id = ?', [productId]);
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Товар не найден' });
        res.json({ message: 'Товар успешно удалён' });
    } catch (err) {
        return handleError(res, err);
    }
});

// Update product
app.put('/products/:id', async (req, res) => {
    const productId = req.params.id;
    const { name, price, description = null, image_id = null } = req.body;
    try {
        if (!name || price == null) return res.status(400).json({ error: 'Название и цена обязательны' });
        const parsedPrice = Number(price);
        if (Number.isNaN(parsedPrice)) return res.status(400).json({ error: 'Цена должна быть числом' });
        const [result] = await pool.query('UPDATE products SET name = ?, price = ?, description = ?, image_id = ? WHERE id = ?', [name, parsedPrice, description, image_id, productId]);
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Товар не найден' });
        res.json({ message: 'Товар успешно обновлён' });
    } catch (err) {
        return handleError(res, err);
    }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('Shutting down...');
    try { await pool.end(); } catch (e) { console.error(e); }
    process.exit(0);
});