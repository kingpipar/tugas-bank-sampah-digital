const db =
    require('../config/sqlConfig');

const getAllLaporan = (req, res) => {
    const query = `
        SELECT
            l.id,
            l.nama_warga,
            h.kategori, /* <---- TAMBAHKAN BARIS INI */
            h.nama_sampah,
            l.berat_kg,
            l.total_harga,
            l.tanggal_setor
        FROM laporan_setoran l
        JOIN harga_sampah h
        ON l.id_sampah = h.id
        ORDER BY l.id DESC
    `;
    db.query(query, (err, result) => {
        if (err) return res.status(500).json({ success: false, message: 'Gagal mengambil laporan' });
        res.json(result);
    });
};


const addLaporan = (req, res) => {

    console.log(req.body);

    const {

        nama_warga,

        id_sampah,

        berat_kg,

        total_harga

    } = req.body;

    const query = `

        INSERT INTO laporan_setoran
        (

            nama_warga,

            id_sampah,

            berat_kg,

            total_harga

        )

        VALUES (?, ?, ?, ?)

    `;

    db.query(

        query,

        [

            nama_warga,

            parseInt(id_sampah),

            parseFloat(berat_kg),

            parseInt(total_harga)

        ],

        (err, result) => {

            // ERROR DATABASE

            if (err) {

                console.log('MYSQL ERROR:');

                console.log(err);

                return res.status(500).json({

                    success: false,

                    error:
                        err.sqlMessage

                });

            }

            // SUCCESS

            res.status(201).json({

                success: true,

                message:
                    'Berhasil tambah laporan'

            });

        }

    );

};

module.exports = {

    getAllLaporan,

    addLaporan

};