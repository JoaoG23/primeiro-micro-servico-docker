const { Pool } = require('pg');
    const poolConexao = new Pool({
    user: process.env.USERDB,
    host:process.env.HOSTDB,
    database:process.env.DATABASE,
    password:process.env.PASSWORD,
    port:process.env.PORTDB,
    idleTimeoutMillis: 0,
    connectionTimeoutMillis: 0,
    max: 10,
    // ssl: {
    //     rejectUnauthorized: false,
    // }
});

module.exports =  poolConexao ;