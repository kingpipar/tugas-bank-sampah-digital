const express = require('express');
const router = express.Router();
const laporanController = require('../controllers/laporanController');

router.get('/', laporanController.getAll);
router.post('/', laporanController.create);
router.delete('/:id', laporanController.remove);
router.get('/stats', laporanController.getStats);

module.exports = router;