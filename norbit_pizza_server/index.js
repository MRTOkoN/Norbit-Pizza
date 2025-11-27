const express = require('express');
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const cors = require('cors');
const multer = require('multer');
const morgan = require('morgan');
const helmet = require('helmet');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
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

    const createOrdersTable = `
        CREATE TABLE IF NOT EXISTS orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_name VARCHAR(255),
            phone VARCHAR(50),
            address TEXT,
            items LONGTEXT,
            total DECIMAL(10,2) NOT NULL,
            order_number VARCHAR(8) NOT NULL,
            UNIQUE KEY unique_order_number (order_number),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )`;

    const conn = await pool.getConnection();
    try {
        await conn.query(createImagesTable);
        await conn.query(createProductsTable);
            await conn.query(createOrdersTable);
        // Ensure `order_number` column and unique index exist (in case table existed prior to adding it)
        try {
            const dbName = process.env.DB_NAME || 'norbit_pizza';
            const [colRows] = await conn.query(
                'SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?',
                [dbName, 'orders', 'order_number']
            );
            const colCount = (colRows && colRows[0] && colRows[0].cnt) || 0;
            if (colCount === 0) {
                await conn.query("ALTER TABLE orders ADD COLUMN order_number VARCHAR(8) NOT NULL");
            }

            // Check if unique index exists; if not, create it
            const [idxRows] = await conn.query(
                'SELECT COUNT(*) AS cnt FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND INDEX_NAME = ?',
                [dbName, 'orders', 'unique_order_number']
            );
            const idxCount = (idxRows && idxRows[0] && idxRows[0].cnt) || 0;
            if (idxCount === 0) {
                await conn.query('ALTER TABLE orders ADD UNIQUE KEY unique_order_number (order_number)');
            }
        } catch (e) {
            console.warn('DB: Could not ensure order_number column/index:', e.message || e);
        }

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

// Create order
app.post('/orders', async (req, res) => {
    try {
        const { customer_name = null, phone = null, address = null, items, total } = req.body;
        if (!items || !Array.isArray(items) || total == null) return res.status(400).json({ error: 'Items (array) and total are required' });

        const itemsJson = JSON.stringify(items);

        // Helper to generate code: one uppercase letter + 3 digits, e.g. A123
        function genOrderNumber() {
            const letter = String.fromCharCode(65 + Math.floor(Math.random() * 26));
            const digits = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
            return (letter + digits).toUpperCase();
        }

        const conn = await pool.getConnection();
        try {
            // Try inserting with a generated order number, retry on duplicate
            let orderNumber = genOrderNumber();
            let attempts = 0;
            let insertId = null;
            while (attempts < 6) {
                try {
                    const [result] = await conn.query(
                        'INSERT INTO orders (customer_name, phone, address, items, total, order_number) VALUES (?, ?, ?, ?, ?, ?)',
                        [customer_name, phone, address, itemsJson, total, orderNumber]
                    );
                    insertId = result.insertId;
                    break;
                } catch (e) {
                    // Duplicate order number? MySQL duplicate entry error code is ER_DUP_ENTRY
                    if (e && e.code === 'ER_DUP_ENTRY') {
                        attempts++;
                        orderNumber = genOrderNumber();
                        continue;
                    }
                    throw e;
                }
            }

            if (insertId == null) return res.status(500).json({ error: 'Не удалось сгенерировать уникальный номер заказа' });

            res.status(201).json({ id: insertId, order_number: orderNumber, message: 'Заказ принят' });
        } finally {
            conn.release();
        }
    } catch (err) {
        return handleError(res, err);
    }
});