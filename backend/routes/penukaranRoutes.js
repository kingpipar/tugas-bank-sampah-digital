const express = require('express');
const router = express.Router();
const penukaranController = require('../controllers/penukaranController');

router.get('/', penukaranController.getAll);
router.post('/', penukaranController.create);
router.put('/:id', penukaranController.update);
router.delete('/:id', penukaranController.remove);

module.exports = router;
