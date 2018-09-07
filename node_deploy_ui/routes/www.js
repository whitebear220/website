#!/usr/bin/env node
var http = require('http');
var debug = require('debug')('my-application');
var app = require('../app');
var socket = require('./socket');

app.set('port', process.env.PORT || 3001);

var server = http.createServer(app);

//启动HTTP 服务时，注入Socket.io
socket.io(server);

server.listen(app.get('port'), '127.0.0.1', function(err) {
	if(err){
        throw err;
    }else{
        console.log("server start on "+(process.env.PORT || 3000)+"...")
    }
});