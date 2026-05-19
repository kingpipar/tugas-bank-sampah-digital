const express = require('express');
const router = express.Router();
const hargaController = require('../controllers/hargaController');

router.get('/', hargaController.getAll);
router.post('/', hargaController.create);
router.put('/:id', hargaController.update);
router.delete('/:id', hargaController.remove);

module.exports = router;