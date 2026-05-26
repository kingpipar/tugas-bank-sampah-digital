const express = require('express');
const router = express.Router();

const {
    login
} = require('../controllers/authController');

router.post('/login', login);
router.put('/update-profile', authController.updateProfile);
router.put('/change-password', authController.changePassword);

module.exports = router;