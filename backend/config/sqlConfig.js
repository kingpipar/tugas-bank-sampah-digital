const mysql =
require('mysql2');

const db =
mysql.createConnection({

    host: 'localhost',

    user: 'root',

    password: '',

    database: 'bank_sampah_digital'

});

db.connect((err) => {

    if (err) {

        console.log(err);

    }

    else {

        console.log(
            'Berhasil terhubung ke database MySQL!'
        );

    }

});

module.exports =
db;