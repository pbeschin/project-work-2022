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
        database: 'ParcheggioDB',
        rowCollectionOnDone:true
    }
};  
var connection = new Connection(config);  
connection.on('connect', function(err) {  
    if (err) {
        console.log(`Not connected\n${err}`);
    } else {
        console.log("Connected");
    }
});

connection.connect();

router.put('/stato/:idEsp', (req, res) => {
    request = new Request("UPDATE TPosti SET presenza = @statoEsp WHERE ID_posto = @idEsp", function(err) {  
        if (err) {  
           console.log(err);}  
    });  
    request.addParameter('idEsp', TYPES.VarChar, req.params.idEsp);  
    request.addParameter('statoEsp', TYPES.Bit , req.body.statoEsp);  
    
    
    request.on("doneInProc", function (rowCount, more, rows) {
        rowCount ? res.status(201) : res.status(404);
    });
    request.on("requestCompleted", function () {
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
    var resStatus = 404;
    request.on("doneInProc", function (rowCount, more, rows) {
        if(rowCount){
            resStatus=201;
        }
    });
    request.on("requestCompleted", function () {
        res.status(resStatus).end();
    });
       
    connection.execSql(request);  
});


router.get('/stato/:idEsp', (req, res) => {
    request = new Request("SELECT presenza FROM TPosti WHERE ID_posto = @idEsp", function(err) {  
        if (err) {  
            console.log(err);}  
    });  
    request.addParameter('idEsp', TYPES.VarChar, req.params.idEsp);
    var result;  
    request.on('row', function(columns) {  
        result = columns[0].value; 
    });  
    
    request.on("requestCompleted", function (rowCount, more, rows) {
        rowCount ? res.status(201).json(result) : res.status(404).end();
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
    
    request.on("requestCompleted", function (rowCount, more, rows) {
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
    
    request.on("requestCompleted", function (rowCount, more, rows) {
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
    
    request.on("requestCompleted", function (rowCount, more, rows) {
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
    
    request.on("requestCompleted", function (rowCount, more, rows) {
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

    request.on("requestCompleted", function (rowCount, more, rows) {
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

    request.on("requestCompleted", function (rowCount, more, rows) {
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

    request.on("requestCompleted", function (rowCount, more, rows) {
        res.json(result);
    });

    connection.execSql(request); 
});

router.get('/transazioni/settimanaScorsa', (req, res) => {
    request = new Request("SET DATEFIRST 1; SELECT * FROM Transazioni_Settimana_Scorsa", function(err) {  
        if (err) {  
            console.log(err);
        }  
        });  
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.giorno = columns[0].value;
        tmp.n_transazioni = columns[1].value;
        result.push(tmp);
    });  
    request.on("requestCompleted", function (rowCount, more, rows) {
        res.json(result);
    });

    connection.execSql(request); 
});

router.post('/transazioni/:ID_rfid', (req, res) => {
    request = new Request("IF NOT EXISTS(SELECT * FROM TPagamenti s " +
        "WHERE ID_rfid=@ID_rfid AND data_uscita IS NULL) "+
        "BEGIN INSERT INTO TPagamenti (ID_rfid,data_entrata) VALUES(@ID_rfid,@data_entrata);END", function(err) {  
        if (err) {  
            console.log(err);
        }
    });  
    request.addParameter('ID_rfid', TYPES.VarChar, req.params.ID_rfid);  
    request.addParameter('data_entrata', TYPES.DateTime , req.body.data_entrata);
    
    request.on("doneInProc", function (rowCount, more, rows){
        rowCount ? res.status(201) : res.status(404);
    });
    request.on("requestCompleted", function (rowCount, more, rows) {
        res.end();
    });

    connection.execSql(request);  
});

router.put('/transazioni/uscita/:ID_rfid', (req, res) => {
    request = new Request(`UPDATE TPagamenti SET data_uscita=@du WHERE ID_rfid=@id AND data_uscita IS NULL; EXEC CalcolaImporto @data_uscita=@du, @ID_rfid=@id`, function(err) {  
    if (err) {  
        console.log(err);}  
    });  
    request.addParameter('id', TYPES.VarChar, req.params.ID_rfid);  
    request.addParameter('du', TYPES.DateTime, req.body.data_uscita);

    var resStatus = 404;
    request.on("doneInProc", function (rowCount, more, rows) {
        if (rowCount){
            resStatus = 201;
        }
    });

    request.on("requestCompleted", function (rowCount, more, rows) {
        res.status(resStatus).end();
    });

    connection.execSql(request);  
});

router.put('/transazioni/pagamento/:ID_rfid', (req, res) => {
    request = new Request("UPDATE TPagamenti SET pagato=1 WHERE ID_rfid = @ID_rfid AND pagato=0", function(err) {  
    if (err) {  
        console.log(err);}  
    });  
    request.addParameter('ID_rfid', TYPES.VarChar, req.params.ID_rfid);  
    request.addParameter('data_uscita', TYPES.DateTime, req.body.data_uscita);

    request.on("doneInProc", function (rowCount, more, rows) {
        console.log(rowCount, more, rows);
        rowCount ? res.status(201) : res.status(404);
    });

    request.on("requestCompleted", function (rowCount, more, rows) {
        res.end();
    });

    connection.execSql(request);  
});

router.get('/transazioni/lista', (req, res) => {
    var request;

    if (req.query.data_uscita_inizio && req.query.data_uscita_fine) {
        request = new Request("SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti WHERE data_uscita BETWEEN @data_uscita_inizio AND @data_uscita_fine", function(err) {  
            if (err) {  
                console.log(err);
            }  
        });
        if (req.query.data_uscita_inizio) {
            request.addParameter('data_uscita_inizio', TYPES.DateTime, req.query.data_uscita_inizio);
        } else {
            request.addParameter('data_uscita_inizio', TYPES.DateTime, '01-01-1753 00:00:00.000');
        }
        if (req.query.data_uscita_fine) {
            request.addParameter('data_uscita_fine', TYPES.DateTime, req.query.data_uscita_fine);
        } else {
            request.addParameter('data_uscita_fine', TYPES.DateTime, new Date().toISOString().split('T')[0]);
        }
        
    } else {
        request = new Request("SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti", function(err) {  
            if (err) {  
                console.log(err);
            }  
        });
    }
    
    var result = [];
    
    request.on('row', function(columns) { 
        var tmp = {};
        tmp.ID_rfid = columns[0].value;
        tmp.data_entrata = columns[1].value;
        tmp.data_uscita = columns[2].value;
        tmp.importo = columns[3].value;
        tmp.pagato = columns[4].value;
        result.push(tmp);
    });  
    request.on("requestCompleted", function (rowCount, more, rows) {
        res.json(result);
    });

    connection.execSql(request); 
});


router.put('/tariffe', (req, res) => {
    request = new Request("UPDATE Ttariffe SET costo_forzato=@costo_forzato WHERE giorno = @giorno", function(err) {  
    if (err) {  
        console.log(err);}  
    });  

    request.addParameter('giorno', TYPES.Date, new Date().toISOString().split('T')[0]);
    request.addParameter('costo_forzato', TYPES.Float, req.body.costo_forzato);
    
    request.on("doneInProc", function (rowCount, more, rows) {
        rowCount ? res.status(201) : res.status(404);
    });
    request.on("requestCompleted", function () {
        res.end();
    });


    connection.execSql(request);  
});

module.exports = router;
