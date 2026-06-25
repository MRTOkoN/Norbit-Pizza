'use strict';

const { z } = require('zod');

const idParam = z.object({
    id: z.coerce
        .number({ invalid_type_error: 'Некорректный идентификатор' })
        .int('Некорректный идентификатор')
        .positive('Некорректный идентификатор'),
});

const optionalText = (max) =>
    z.coerce
        .string()
        .trim()
        .max(max)
        .nullish()
        .transform((v) => (v === undefined || v === '' ? null : v));

const toNumberPreserveMissing = (v) => {
    if (v === undefined || v === null) return undefined;
    if (typeof v === 'number') return v;
    if (typeof v === 'string') {
        const n = Number(v);
        return Number.isNaN(n) ? v : n;
    }
    return v;
};

const productBody = z.object({
    name: z
        .string({ required_error: 'Название и цена обязательны', invalid_type_error: 'Название и цена обязательны' })
        .trim()
        .min(1, 'Название и цена обязательны')
        .max(255, 'Название слишком длинное (макс. 255 символов)'),
    price: z.preprocess(
        toNumberPreserveMissing,
        z
            .number({ required_error: 'Название и цена обязательны', invalid_type_error: 'Цена должна быть числом' })
            .refine((n) => Number.isFinite(n), 'Цена должна быть числом')
            .refine((n) => n >= 0, 'Цена не может быть отрицательной')
    ),
    description: optionalText(5000),
    image_id: z.coerce
        .number()
        .int()
        .positive()
        .nullish()
        .transform((v) => (v === undefined ? null : v)),
});

const orderBody = z.object({
    customer_name: optionalText(255),
    phone: optionalText(50),
    address: optionalText(2000),
    items: z.array(z.any(), {
        required_error: 'Items (array) and total are required',
        invalid_type_error: 'Items (array) and total are required',
    }),
    total: z.preprocess(
        toNumberPreserveMissing,
        z
            .number({ required_error: 'Items (array) and total are required', invalid_type_error: 'Items (array) and total are required' })
            .refine((n) => Number.isFinite(n), 'Items (array) and total are required')
            .refine((n) => n >= 0, 'Сумма не может быть отрицательной')
    ),
});

module.exports = { idParam, productBody, orderBody };
