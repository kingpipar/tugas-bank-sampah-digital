const express =
require('express');

const router =
express.Router();

const {

    getHargaSampah

} = require('../controllers/hargaController');

router.get(
    '/',
    getHargaSampah
);

module.exports =
router;