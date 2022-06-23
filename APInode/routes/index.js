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
        getModalita();
    }
});

var modalitaCalcolo;

connection.connect();

function getModalita(){
    request = new Request("SELECT TOP 1 mod_tariffa FROM TConfig", function(err) {  
        if (err) {  
           console.log(err);}  
    });  
    
    request.on("row", function (columns) {
        modalitaCalcolo = columns[0].value;
    });
    request.on("requestCompleted", function () {
        console.log(modalitaCalcolo)
    });
    connection.execSql(request);  
}

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

router.get('/lista/stato', (req, res) => {
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

router.get('/lista/stato/terra', (req, res) => {
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

router.get('/lista/stato/primo', (req, res) => {
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

router.get('/postiOccupati', (req, res) => {
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

router.post('/transazioni/:ID_rfid', (req, res) => {
    var ora = new Date(req.body.data_entrata).getHours();
    if (ora >= 6 && ora <= 23) {
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
            rowCount ? res.status(201) : res.status(400);
        });
        request.on("requestCompleted", function (rowCount, more, rows) {
            res.end();
        });

        connection.execSql(request);
    } else {
        res.status(404).end();
    }
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

router.get('/lista/transazioni', (req, res) => {
    var sqlCommand;
    if (req.query.data_uscita_inizio && req.query.data_uscita_fine) {
        sqlCommand = "SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti WHERE data_uscita BETWEEN @data_uscita_inizio AND @data_uscita_fine;";
    }
    else if (req.query.data_uscita_inizio) {
        sqlCommand = "SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti WHERE data_uscita > @data_uscita_inizio;";
    } else if (req.query.data_uscita_fine) {
        sqlCommand = "SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti WHERE data_uscita < @data_uscita_fine;";
    } else {
        sqlCommand = "SELECT ID_rfid, data_entrata, data_uscita, importo, pagato FROM TPagamenti";
    }
    
    request = new Request(sqlCommand, function(err) {  
        if (err) {  
            console.log(err);
        }  
    });

    request.addParameter('data_uscita_inizio', TYPES.DateTime, req.query.data_uscita_inizio);
    request.addParameter('data_uscita_fine', TYPES.DateTime, req.query.data_uscita_fine);
    
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

router.put('/transazioni/:ID_rfid/uscita', (req, res) => {
    var ora = new Date(req.body.data_uscita).getHours();
    if (ora >= 6 && ora <= 23) {
        var sqlCommand = "UPDATE TPagamenti SET data_uscita=@du WHERE ID_rfid=@id AND data_uscita IS NULL;";
        sqlCommand += "EXEC CalcolaImporto_3TariffeOrarie @data_uscita=@du, @ID_rfid=@id;";
        sqlCommand += "SELECT importo FROM TPagamenti WHERE ID_rfid=@id AND pagato=0;";
        request = new Request(sqlCommand, function(err){
            if (err) {  
                console.log(err);}  
        });  

        request.addParameter('id', TYPES.VarChar, req.params.ID_rfid);  
        request.addParameter('du', TYPES.DateTime, req.body.data_uscita);

        var amount;
        var resStatus = 404;
        request.on("doneInProc", function (rowCount, more, rows) {
            if (rowCount){
                resStatus = 200;
            }
        });

        request.on("row", function(columns) {
            amount = columns[0].value;
            console.log("row");
        });
        request.on("requestCompleted", function (rowCount, more, rows) {
            res.status(resStatus).json({"prezzo": amount});
            console.log("res");
        });

        connection.execSql(request);
    } else {
        res.status(404).end();
    }  
});

router.put('/transazioni/:ID_rfid/pagamento', (req, res) => {
    var ora = new Date().getHours();
    if (ora >= 6 && ora <= 23) {
        request = new Request("UPDATE TPagamenti SET pagato=1 WHERE ID_rfid = @ID_rfid AND pagato=0", function(err) {  
        if (err) {  
            console.log(err);}  
        });  
        request.addParameter('ID_rfid', TYPES.VarChar, req.params.ID_rfid);  

        request.on("doneInProc", function (rowCount, more, rows) {
            console.log(rowCount, more, rows);
            rowCount ? res.status(201) : res.status(400);
        });

        request.on("requestCompleted", function (rowCount, more, rows) {
            res.end();
        });

        connection.execSql(request);  
    } else {
        res.status(404).end();
    }
});

router.get('/modalitaTariffa', (req, res) => {
    request = new Request("SELECT TOP 1 mod_tariffa FROM TConfig", function(err){
        if (err) {  
            console.log(err);}  
    });  

    var result;
    request.on("row", function (columns) {
        result = columns[0].value;
    });

    request.on("requestCompleted", function (rowCount, more, rows) {
        res.json(result)
    });

    connection.execSql(request);  
});

router.put('/modalitaTariffa/:modalita', (req, res) => {
    var sqlCommand = "";
    if (req.params.modalita == '0' || req.params.modalita == '1') {
        sqlCommand = "UPDATE Ttariffe SET costo_forzato=NULL WHERE giorno=@giorno;"
    }
    sqlCommand += "UPDATE TConfig SET mod_tariffa=@modalita";
    request = new Request(sqlCommand, function(err) {
        if (err) {  
            console.log(err);}  
    });  
    
    request.addParameter('modalita', TYPES.Int, req.params.modalita);
    request.addParameter('giorno', TYPES.Date, new Date().toISOString().split('T')[0]);

    var result;
    request.on("row", function (columns) {
        result = columns[0].value;
    });

    request.on("requestCompleted", function (rowCount, more, rows) {
        modalitaCalcolo = req.params.modalita;
        res.json(result);
    });

    connection.execSql(request);  
});

router.put('/tariffe', (req, res) => {
    request = new Request("UPDATE Ttariffe SET costo_forzato=@costo_forzato WHERE giorno = @giorno; UPDATE TConfig SET mod_tariffa=2", function(err) {  
    if (err) {  
        console.log(err);}  
    });  
    
    request.addParameter('giorno', TYPES.Date, new Date().toISOString().split('T')[0]);
    request.addParameter('costo_forzato', TYPES.Float, req.body.costo_forzato);
    
    request.on("doneInProc", function (rowCount, more, rows) {
        rowCount ? res.status(201) : res.status(404);
    });
    request.on("requestCompleted", function () {
        modalitaCalcolo = 2;
        res.end();
    });


    connection.execSql(request);  
});

router.get('/tariffe', (req, res) => {
    request = new Request("SELECT costo_orario, costo_orario_rotazione, costo_forzato FROM Ttariffe WHERE giorno=@giorno", function(err) {  
    if (err) {  
        console.log(err);}  
    });  
    request.addParameter('giorno', TYPES.Date, new Date().toISOString().split('T')[0]);

    var result = {};
    request.on("row", function(columns) {
        result.costo_orario = columns[0].value;
        result.costo_orario_rotazione = columns[1].value;
        result.costo_forzato = columns[2].value;
    });
    request.on("requestCompleted", function () {
        res.json(result);
    });

    connection.execSql(request);  
});

module.exports = router;
