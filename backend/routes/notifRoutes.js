const express = require('express');
const router = express.Router();
const notifController = require('../controllers/notifController');

router.get('/', notifController.getAll);
router.post('/', notifController.create);

module.exports = router;