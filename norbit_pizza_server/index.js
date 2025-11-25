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


// ◦ Структура таблицы товаров


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

// ◦ Запрос на получение товаров
// ◦ Запрос на получение изображения

//Запуск сервера
app.listen(PORT, () => {
    console.log(`Сервер запустился на http://localhost:${PORT}`);
});