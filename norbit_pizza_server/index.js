// TODO: Реализовать функционал согласно ТЗ:


const express = require('express');
const mysql = require('mysql2');
const app = express();
const PORT = 3000;

//Midlleware
app.use(express.json())

// ◦ Подключение к MySQL
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'norbit_pizza'
});

// Проверка подключения
connection.connect((err) => {
    if (err) {
        console.error('Ошибка подключения к MySql:', err.message);
        return;
    }
    console.log('Успешное подключение к MySql database: norbit_pizza');
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

// ◦ Структура таблицы товаров с внешним ключом
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
        console.error('Ошибка создания таблицы images:', err);
        return;
    }
    console.log('Таблица images готова');

    connection.query(createProductsTable, (err) => {
        if (err) {
            console.error('Ошибка создания таблицы products:', err);
            return;
        }
        console.log('Таблица products готова');
        console.log('Обе таблицы успешно создались');
    });
});


// ◦ Метод загрузки изображения в бд
// ◦ Метод запроса изображения из бд
// ◦ Метод удаления изображения из бд
// ◦ Метод добавления товара в бд
// ◦ Метод запроса товара из бд
// ◦ Метод удаления товара из бд
// ◦ Синхронизация товаров с редиса

// ◦ http сервер

//Базовый роут для проверки работы сервера
app.get('/', (req, res) => {
    res.json({message: 'Norbit pizza сервак запущен!'});
});

// ◦ Запрос на получение ВСЕХ пицц (для главной страницы)
app.get('/products', (req, res) => {
    connection.query('SELECT * FROM products', (err, results) => {
        if (err) {
            res.status(500).json({error: err.message});
            return;
        }
        res.json(results);
    });
});

// Запрос на получение пиццы по ID (в корзину)
app.get('/products/:id', (req, res) => {
    const productId = req.params.id;
    connection.query('SELECT * FROM products WHERE id = ?', [productId], (err, results) => {
        if (err) {
            res.status(500).json({error: err.message});
            return;
        }
        if (results.length === 0) {
            res.status(404).json({error: 'Пицца не найдена'});
            return;
        }
        res.json(results[0]);
    });
});

// ◦ Запрос на получение изображения

//Запуск сервера
app.listen(PORT, () => {
    console.log(`Сервер запустился на http://localhost:${PORT}`);
});