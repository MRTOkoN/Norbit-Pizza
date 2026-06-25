'use strict';

const { ZodError } = require('zod');

function validate(schemas) {
    return (req, _res, next) => {
        try {
            req.valid = req.valid || {};
            if (schemas.params) req.valid.params = schemas.params.parse(req.params);
            if (schemas.query) req.valid.query = schemas.query.parse(req.query);
            if (schemas.body) req.valid.body = schemas.body.parse(req.body);
            next();
        } catch (err) {
            if (err instanceof ZodError) {
                const message = err.issues[0]?.message || 'Некорректные данные';
                return next(Object.assign(new Error(message), { status: 400, expose: true }));
            }
            return next(err);
        }
    };
}

module.exports = { validate };
