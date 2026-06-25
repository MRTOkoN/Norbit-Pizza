'use strict';

const { randomInt } = require('node:crypto');

function generateOrderNumber() {
    const letter = String.fromCharCode(65 + randomInt(26));
    const digits = String(randomInt(1000)).padStart(3, '0');
    return letter + digits;
}

module.exports = { generateOrderNumber };
