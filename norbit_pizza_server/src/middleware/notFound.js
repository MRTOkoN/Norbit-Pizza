'use strict';

function notFound(_req, res) {
    res.status(404).json({ error: 'Не найдено' });
}

module.exports = { notFound };
