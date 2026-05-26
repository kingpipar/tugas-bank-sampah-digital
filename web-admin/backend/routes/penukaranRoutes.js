const express = require('express');
const router = express.Router();
const { getAllPenukaran, addPenukaran } = require('../controllers/penukaranController');

router.get('/', getAllPenukaran);
router.post('/', addPenukaran);

module.exports = router;
