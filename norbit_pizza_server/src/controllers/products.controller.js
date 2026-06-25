'use strict';

const productsService = require('../services/products.service');

async function listProducts(_req, res) {
    const products = await productsService.list();
    return res.json(products);
}

async function createProduct(req, res) {
    const { name, price, description, image_id } = req.valid.body;
    const id = await productsService.create({ name, price, description, image_id });
    return res.status(201).json({
        id,
        message: 'Товар успешно добавлен',
        product: { id, name, price, description, image_id },
    });
}

async function updateProduct(req, res) {
    const updated = await productsService.update(req.valid.params.id, req.valid.body);
    if (!updated) {
        return res.status(404).json({ error: 'Товар не найден' });
    }
    return res.json({ message: 'Товар успешно обновлён' });
}

async function deleteProduct(req, res) {
    const removed = await productsService.remove(req.valid.params.id);
    if (!removed) {
        return res.status(404).json({ error: 'Товар не найден' });
    }
    return res.json({ message: 'Товар успешно удалён' });
}

module.exports = { listProducts, createProduct, updateProduct, deleteProduct };
