const express =
require('express');

const router =
express.Router();

const {
    getNotif
} = require('../controllers/notifController');

router.get(
    '/',
    getNotif
);

module.exports =
router;
