const db =
require('../config/sqlConfig');


// GET HARGA SAMPAH

const getHargaSampah = (req, res) => {

    const query =
        'SELECT * FROM harga_sampah';

    db.query(query, (err, result) => {

        if (err) {

            console.log(err);

            return res.status(500).json({

                success: false,

                message:
                    'Gagal mengambil data harga'

            });

        }

        res.json(result);

    });

};


module.exports = {

    getHargaSampah

};