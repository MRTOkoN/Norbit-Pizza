'use strict';

const ordersService = require('../services/orders.service');

async function createOrder(req, res) {
    const order = await ordersService.create(req.valid.body);
    if (!order) {
        return res.status(500).json({ error: 'Не удалось сгенерировать уникальный номер заказа' });
    }
    return res.status(201).json({
        id: order.id,
        order_number: order.orderNumber,
        message: 'Заказ принят',
    });
}

module.exports = { createOrder };
