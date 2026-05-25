const express = require('express');
const router = express.Router();
const { getAllSembako, addSembako, updateSembako, deleteSembako } = require('../controllers/sembakoController');

router.get('/', getAllSembako);
router.post('/', addSembako);
router.put('/:id', updateSembako);
router.delete('/:id', deleteSembako);

module.exports = router;