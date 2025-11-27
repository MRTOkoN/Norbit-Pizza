const express = require('express');
const mysql = require('mysql2');
const app = express();
const PORT = 3000;

// Midlleware
app.use(express.json())

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'norbit_pizza'
});

connection.connect((err) => {
    if (err) {
        console.error('Connection to MySQL error:', err.message);
        return;
    }
    console.log('Conection to MySQL database successful: norbit_pizza');
});


// Структура таблицы изображений
const createImagesTable =  `
  CREATE TABLE IF NOT EXISTS images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100),
    image_data LONGBLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`;

// Структура таблицы товаров с внешним ключом
const createProductsTable = `
  CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    image_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL
  )
`;

// Создаём таблицы последовательно
connection.query(createImagesTable, (err) => {
    if (err) {
        console.error('DB: Image collection create error:', err);
        return;
    }
    console.log('DB: Image collection created successfully');

});

connection.query(createProductsTable, (err) => {
    if (err) {
        console.error('DB: Product collection create error:', err);
        return;
    }
    console.log('DB: Product collection created successfully');
});

// ◦ Метод загрузки изображения в бд
// ◦ Метод запроса изображения из бд
// ◦ Метод удаления изображения из бд
// ◦ Метод добавления товара в бд
// ◦ Метод запроса товара из бд
// ◦ Метод удаления товара из бд
// ◦ Синхронизация товаров с редиса

// Запрос на получение ВСЕХ пицц (для главной страницы)
app.post('/products', (req, res) => {
    const { name, price, description, image_id} = req.body;

    // Проверка обязательных полей
    if (!name || !price) {
        return res.status(500).json({error: 'Назавание и цена обязательны'});
    }

    connection.query(
        'INSERT INTO products (name, price, description, image_id) VALUES (?, ?, ?, ?)',
        [name, price, description, image_id],
        (err, results) => {
            if (err) {
                res.status(500).json({error: err.message});
                return;
            }
            res.json({
                id: results.insertId,
                message: 'Товар успешно добавлен',
                product: { id: results.insertId, name, price, description, image_id}
            })
        }
    );
});

// Метод удаления товара из БД
app.delete('/products/:id', (req, res) => {
    const productId = req.params.id;connection.query('DELETE FROM products WHERE id = ?', [productId], (err, results) => {
        if (err) {
            res.status(500).json({error: err.message});
            return;
        }
        if (results.affectedRows === 0 ) {
            res.status(404).json({error: 'Товар не найден'});
            return;
        }
        res.json({message: 'Товар успешно добавлен в БД'});
    });
});

// Метод обновления товара в БД
app.put('/products/:id', (req, res) => {
    const productId = req.params.id;
    const {name, price, description, image_id} = req.body;

    connection.query(
        'UPDATE products SET name = ?, price = ?, description = ?, image_id = ? WHERE id = ?',
        [name, price, description, image_id, productId],
        (err, results) => {
            if (err) {
                res.status(500).json({error: err.message});
                return;
            }
            if (results.affectedRows === 0) {
                res.status(404).json({error: 'Товар не найден'});
                return;
            }
            res.json({message: 'Товар успешно обновлён'});
        }
    )
})

app.listen(PORT, () => {
    console.log(`Сервер запустился на http://localhost:${PORT}`);
});