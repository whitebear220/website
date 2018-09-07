var parser = require('./parsers');

parser();




// var express = require('express'), spawn = require('child_process').spawn;


// var app = express();
// app.use(app.router);

// var tail;
// app.get('/tail', function(req, res) {
// 	res.header('Content-Type','text/html;charset=utf-8');
	
// 	tail = spawn('tail', ['-f', './test.log']);
// 	tail.stdout.on('data', function(data) {
// 		console.log('stdout: ' + data);
// 		res.write(data, 'utf-8');
// 	});
// 	tail.stderr.on('data', function(data) {
// 		console.log('stderr: ' + data);
// 		res.write(data, 'utf-8');
// 	});
// 	tail.on('exit', function(code) {
// 		console.log('child process exited with code ' + code);
// 		res.end(code);
// 	});
// });
// app.listen(8080);
// console.log('server ' + process.pid + ' running on 8080 port...');
