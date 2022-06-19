var express = require('express');
var morgan = require('morgan');

var indexRouter = require('./routes/index');
//var listaRouter = require('./routes/lista');

var app = express();

app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
//app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
//app.use('/lista', listaRouter);

module.exports = app;
