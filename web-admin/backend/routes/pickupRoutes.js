const express = require('express');
const router = express.Router();
const pickupController = require('../controllers/pickupController');

router.get('/', pickupController.getAll);
router.post('/', pickupController.create);
router.put('/:id', pickupController.update);
router.delete('/:id', pickupController.remove);

module.exports = router;
