const db =
    require('../config/sqlConfig');


// GET ALL LAPORAN

const getAllLaporan = (req, res) => {

    const sql =
        'SELECT * FROM laporan ORDER BY id DESC';

    db.query(sql, (err, result) => {

        if (err) {

            console.log(err);

            return res.status(500).json({

                message:
                    'Gagal mengambil data laporan'

            });

        }

        res.json(result);

    });

};


// ADD LAPORAN

const addLaporan = (req, res) => {

    console.log(req.body);

    const {

        nama_warga,

        nama_sampah,

        berat_kg,

        total_harga

    } = req.body;

    // VALIDASI

    if (

        !nama_warga ||

        !nama_sampah ||

        !berat_kg

    ) {

        return res.status(400).json({

            message:
                'Data tidak lengkap'

        });

    }

    const sql = `

        INSERT INTO laporan
        (

            nama_warga,

            nama_sampah,

            berat_kg,

            total_harga

        )

        VALUES (?, ?, ?, ?)

    `;

    db.query(

        sql,

        [

            nama_warga,

            nama_sampah,

            berat_kg,

            total_harga || 0

        ],

        (err, result) => {

            if (err) {

                console.log(err);

                return res.status(500).json({

                    message:
                        'Gagal menambahkan laporan',

                    error:
                        err

                });

            }

            res.status(201).json({

                message:
                    'Laporan berhasil ditambahkan',

                data:
                    result

            });

        }

    );

};


module.exports = {

    getAllLaporan,

    addLaporan

};