var express = require('express');
var app = express();
var child_process = require('child_process');
var http = require('http').Server(app);
var io = require('socket.io')(http);
var child_process = require('child_process');

exports.io = function(server){
	var io = require('socket.io')(server);
	var system = io.of('/taillog');
	//連接開始
	system.on('connection', function (socket) {
	console.log('123');
		//log路徑
	  var fileName = './log/deploy.log';
	  //使用child_process call 'tail'指令
	  var child = child_process.spawn('tail', ['-f', fileName]);
		//監聽子進程正常結果
	  child.stdout.on('data', function (data) {
		// console.log(data);
		socket.emit('data', data.toString());
	  });
	
	  //監聽子進程錯誤結果
	  child.stderr.on('data', function (data) {
		  console.log('stderr: ' + data.toString());
		  socket.emit('err', data.toString());
	  });
	
	  //監聽子進程退出
	  child.on('close', function (code) {
		  console.log('子进程退出，code：' + code);
		  socket.emit('err', '子进程退出，code：' + code);
	  });
	
		//連接斷開處理
		socket.on('disconnect', function (){
		  
	  });
	});
}