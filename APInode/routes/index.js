var express = require('express');
var router = express.Router();
const fs = require('fs');
var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
var Connection = require('tedious').Connection;  

const passwords = JSON.parse(fs.readFileSync('./passwords.json', {encoding:'utf8'}));

var config = {  
    server: 'beschin.database.windows.net',
    authentication: {
        type: 'default',
        options: {
            userName: passwords["AzureDB"]["username"],
            password: passwords["AzureDB"]["password"]
        }
    },
    options: {
        // If you are on Microsoft Azure, you need encryption:
        encrypt: true,
        database: 'ParcheggioDB'
    }
};  
var connection = new Connection(config);  
connection.on('connect', function(err) {  
    // If no error, then good to proceed.
    console.log("Connected");  
});

connection.connect();

router.put('/stato/:idEsp', (req, res) => {
    request = new Request("UPDATE TPosti SET presenza = @statoEsp WHERE ID_posto = @idEsp", function(err) {  
        if (err) {  
           console.log(err);}  
       });  
       request.addParameter('idEsp', TYPES.VarChar, req.params.idEsp);  
       request.addParameter('statoEsp', TYPES.Bit , req.body.statoEsp);  
       request.on('row', function(columns) {  
           columns.forEach(function(column) {  
             if (column.value === null) {  
               console.log('NULL');  
             } else {  
               console.log("Product id of inserted item is " + column.value);  
             }  
           });  
       });

       request.on("requestCompleted", function (rowCount, more) {
        res.end();
       });

       connection.execSql(request);  
});

router.put('/stato', (req, res) => {
    var commandSql = "";
    req.body.forEach(item => {
        commandSql += `UPDATE Tposti SET presenza = ${item.statoEsp} WHERE ID_posto = ${item.idEsp};`;
    });
    
    var request = new Request(commandSql, function(err) {  
        if (err) {  
           console.log(err);}  
       });

       request.on("requestCompleted", function (rowCount, more) {
        res.end();
       });
       
    connection.execSql(request);  
});


router.get('/stato/:idEsp', (req, res) => {
    request = new Request("SELECT presenza FROM TPosti WHERE ID_posto = @idEsp", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    request.addParameter('idEsp', TYPES.VarChar, req.params.idEsp);
    var result = "";  
    request.on('row', function(columns) {  
        columns.forEach(function(column) {  
            if (column.value === null) {  
            console.log('NULL');  
            } else {  
            result+= column.value + " ";  
            }  
        });  
    });  
    
    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/lista', (req, res) => {
    request = new Request("SELECT ID_posto, presenza FROM TPosti", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.ID_posto = columns[0].value;
        tmp.presenza = columns[1].value;
        result.push(tmp);
    });  
    
    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/lista/terra', (req, res) => {
    request = new Request("SELECT * FROM TPosti WHERE LEFT(ID_Posto,1) = '0'", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.ID_posto = columns[0].value;
        tmp.presenza = columns[1].value;
        result.push(tmp);
    });    
    
    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/lista/primo', (req, res) => {
    request = new Request("SELECT * FROM TPosti WHERE LEFT(ID_Posto,1) = '1'", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.ID_posto = columns[0].value;
        tmp.presenza = columns[1].value;
        result.push(tmp);
    });  
    
    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/lista/posti_occupati', (req, res) => {
    request = new Request("SELECT ID_posto FROM TPosti WHERE presenza = 1", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        result.push(columns[0].value);
    });   
    
    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});


router.get('/tempoMedio', (req, res) => {
    request = new Request("SELECT * FROM Tempo_Medio_Affluenza", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result;
    
    request.on('row', function(columns) { 
        result = columns[0].value;
    });  

    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/countPosti', (req, res) => {
    request = new Request("SELECT COUNT(ID_posto) FROM TPosti WHERE presenza = 1", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result;
    
    request.on('row', function(columns) { 
        result = columns[0].value;
    });  

    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/transazioni/settimanaCorrente', (req, res) => {
    request = new Request("SET DATEFIRST 1; SELECT * FROM Transazioni_Settimana_Corrente", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.giorno = columns[0].value;
        tmp.n_transazioni = columns[1].value;
        result.push(tmp);
    });  

    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.get('/transazioni/settimanaScorsa', (req, res) => {
    request = new Request("SET DATEFIRST 1; SELECT * FROM Transazioni_Settimana_Scorsa", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.giorno = columns[0].value;
        tmp.n_transazioni = columns[1].value;
        result.push(tmp);
    });  

    request.on("requestCompleted", function (rowCount, more) {
        res.json(result);
    });
    connection.execSql(request); 
});

router.post('/pagamenti/:ID_rfid', (req, res) => {
    request = new Request("IF NOT EXISTS(SELECT * FROM TPagamenti s " +
        "WHERE ID_rfid=@ID_rfid AND data_uscita IS NULL) "+
        "BEGIN INSERT INTO TPagamenti (ID_rfid,data_entrata,pagato) VALUES(@ID_rfid,@data_entrata,@pagato);END", function(err) {  
        if (err) {  
            console.log(err);
        }
    });  
    request.addParameter('ID_rfid', TYPES.VarChar, req.params.ID_rfid);  
    request.addParameter('data_entrata', TYPES.DateTime , req.body.data_entrata);
    request.addParameter('pagato', TYPES.Bit, 0);
    request.on('row', function(columns) {  
        columns.forEach(function(column) {  
            if (column.value === null) {  
            console.log('NULL');  
            } else {  
            console.log("Product id of inserted item is " + column.value);  
            }  
        });  
    });
    request.on("row", function (columns) {
        console.log(column[0].value)
    });
    request.on("requestCompleted", function (rowCount, more) {
        res.end();
    });
    connection.execSql(request);  
});

router.put('/pagamenti/:ID_rfid', (req, res) => {
    request = new Request("UPDATE TPagamenti SET data_uscita=@data_uscita, importo=@importo, pagato=@pagato WHERE ID_rfid = @ID_rfid AND data_uscita IS NULL", function(err) {  
    if (err) {  
        console.log(err);}  
    });  
    request.addParameter('ID_rfid', TYPES.VarChar, req.params.ID_rfid);  
    request.addParameter('data_uscita', TYPES.DateTime, req.body.data_uscita);
    request.addParameter('importo', TYPES.Decimal, req.body.importo)
    request.addParameter('pagato', TYPES.Bit, req.body.pagato);
    request.on('row', function(columns) {  
        columns.forEach(function(column) {  
            if (column.value === null) {  
            console.log('NULL');  
            } else {  
            console.log("Product id of inserted item is " + column.value);  
            }  
        });  
    });

    request.on("requestCompleted", function (rowCount, more) {
    res.end();
    });
    connection.execSql(request);  
});

module.exports = router;
