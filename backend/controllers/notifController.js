const getNotif = async (req, res) => {

    res.json({

        success: true,

        message:
            'Data notifikasi berhasil diambil'

    });

};

module.exports = {

    getNotif

};