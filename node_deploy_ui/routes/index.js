var express = require('express');
var router = express.Router();
var passport = require('passport');
//var shell = require('shelljs');
var json = require('jsonfile');
var fs = require('fs');
//處理json格式
var bodyParser = require('body-parser');
// var app = express(); 
router.use(bodyParser.json());
router.use(bodyParser.urlencoded({ extended: false }));
//shell script
var shell = require('shelljs');
var exec = require("child_process").exec;
var parser = require('./parsers');
var url = require('url');
var openvpn = require('./openvpn.js');

router.get(
  '/',
  function(req, res) {
    res.render('login/login', { user: req.user });
  });

router.get('/login',
  function(req, res){
    res.render('login/login');
  });

router.post('/login', 
  passport.authenticate('local', { failureRedirect: '/login' }),
  function(req, res) {
    res.redirect('/start');
  });

router.get('/logout',
  function(req, res){
    req.logout();
    res.redirect('login');
  });

router.get('/profile',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    res.render('file/profile', { user: req.user });
  });

router.get('/do',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    // shell.exec('sh cmd/do.sh');
    exec("sh cmd/do.sh", function (error, stdout, stderr) {
      content = stdout;
    });
    res.render('file/do', { user: req.user });
  });

var spawn = require('child_process').spawn;

router.get('/tail', function(req, res) {
    res.writeHead(200, {"Content-Type": "application/json"});
    
    var tail = spawn('tail', ['-f', './out.log']);
    tail.stdout.on('data', function(data) {
      console.log('stdout: ' + data);
      // linesArray = data.toString().split("\n")
      // res.write(linesArray[0]);
      res.write(JSON.stringify(data));
    });
    tail.stderr.on('data', function(data) {
      console.log('stderr: ' + data);
      res.write(data, 'utf-8');
    });
    tail.on('exit', function(code) {
      console.log('child process exited with code ' + code);
      res.end(code);
    });
});


router.get('/form',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    fs.readFile('output.json', 'utf8', function(err, data) {
      if (err) {
        throw err;
      } 
      data = JSON.parse();
      console.log("讀取成功!"); 
      console.log(data);   
      res.render('file/form', { user: req.user, data: data });
    });
    // res.render('file/form', { user: req.user });
  }); 

  router.get('/data',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    fs.readFile('output.json', 'utf8', function(err, data) {
      if (err) {
        throw err;
      } 
      data = JSON.parse(data);
      console.log("讀取成功!"); 
      console.log(data);   
      res.render('file/data', { user: req.user, data: data });
    });
  }); 

router.post('/formadd',
  require('connect-ensure-login').ensureLoggedIn(),
  // passport.authenticate('local', { failureRedirect: '/login1' }),
  function(req, res, next){
    console.log(req.body);
    var data = JSON.stringify(req.body);
    console.log(data);
    json.writeFile('output.json', req.body, function(err) {
      if (err) {
        throw err;
      } 
      console.log("寫入成功!");
    });
    res.redirect('/data');
}); 

router.get('/start',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    res.render('file/start', { user: req.user });
  }); 
router.get('/date',
  require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    fs.readFile('output.json', 'utf8', function(err, data) {
      if (err) {
        throw err;
      } 
      data = JSON.parse(data);
      console.log("讀取成功!"); 
      console.log(data);   
      res.render('file/alldeployconfig', { user: req.user, data: data });
    });
});   

router.post('/dateadd',
require('connect-ensure-login').ensureLoggedIn(),
// passport.authenticate('local', { failureRedirect: '/login1' }),
function(req, res, next){
  console.log(req.body);
  var data = JSON.stringify(req.body);
  console.log(data);
  json.writeFile('output_date.json', req.body, function(err) {
    if (err) {
      throw err;
    } 
    console.log("寫入成功!");
  });
  res.redirect('/port');
});

router.get('/port',
require('connect-ensure-login').ensureLoggedIn(),
function(req, res){
  fs.readFile('output.json', 'utf8', function(err, data) {
    if (err) {
      throw err;
    } 
    data = JSON.parse(data);
    console.log("讀取成功!"); 
    console.log(data);   
    res.render('file/port', { user: req.user, data: data });
  });
});   

router.post('/portadd',
require('connect-ensure-login').ensureLoggedIn(),
// passport.authenticate('local', { failureRedirect: '/login1' }),
function(req, res, next){
console.log(req.body);
var data = JSON.stringify(req.body);
console.log(data);
json.writeFile('output_port.json', req.body, function(err) {
  if (err) {
    throw err;
  } 
  console.log("寫入成功!");
});
res.redirect('/form');
});

router.get('/alldeployconfig',
require('connect-ensure-login').ensureLoggedIn(),
function(req, res){
  // fs.readFile('output.json', 'utf8', function(err, data1) {
  //   if (err) {
  //     throw err;
  //   } 
  data = parser.parser_out();
  // console.log(data);
    // data = JSON.parse(tmp);
    // data = JSON.parse(data1);
    console.log("讀取成功!");
    console.log(data);
    res.render('file/alldeployconfig', { user: req.user, data: data });
  // });
});

router.get('/deploycheck',
require('connect-ensure-login').ensureLoggedIn(),
function(req, res){
  fs.readFile('output.json', 'utf8', function(err, data) {
    if (err) {
      throw err;
    } 
    data = JSON.parse(data);
    console.log("讀取成功!"); 
    console.log(data);   
    res.render('file/deploycheck', { user: req.user, data: data });
  });
}); 

router.post('/configadd',
require('connect-ensure-login').ensureLoggedIn(),
// passport.authenticate('local', { failureRedirect: '/login1' }),
function(req, res, next){
  console.log(req.body);
  console.log(req.query);
  console.log(req.params);
  console.log('123');
   var data = JSON.stringify(req.body);
   console.log(data);
  json.writeFile('output.json', req.body, function(err) {
    if (err) {
      throw err;
    } 
    console.log("寫入成功!");

  });
  parser.parser_in(data);
  res.redirect('/deploycheck');
}); 

router.post('/todo',
require('connect-ensure-login').ensureLoggedIn(),
  function(req, res){
    var child = exec("/bin/bash deploy.sh ONE", function (error, stdout, stderr) {
      // exec("sh test.sh", function (error, stdout, stderr) {
        //  content = stdout;
        //  res.write(content);
        console.log(stdout);
    });
    res.render('file/socket', { user: req.user });
});

router.get('/log',
function(req, res){
  var data = 'http://localhost:3001/tail'
  res.render('file/socket', { user: req.user, data: data });
  // res.send('ok');
});

// var http = require('http');
// var socket = require('./socket');
// var server = require('http').Server(app);
// socket.io(server);

router.post('/status',
function(req, res, next){
  console.log(req.headers);
  console.log(req.body);
  for (var key in req.body) {
    if ( key == "step" ){
      json.writeFile('output_date.json', req.body, function(err) {
        if (err) {
          throw err;
        } 
        console.log("寫入成功!");
        res.send('success'+'\n');
      });
    }else{
      console.log("寫入失敗!");
      console.log("格式為："+ JSON.stringify(req.body));
      res.send('fail'+'\n');
    }
  }
  // res.send('success');

});
//curl -X POST -H "application/x-www-form-urlencoded" http://localhost:3000/status -d 'step1=1'


router.get('/openvpn',
function(req, res, next){
  // var data = new Object;
  data = openvpn();
  // var data = eval('(' + openvpn() + ')');
  // data = '\'' +openvpn() + '\'';
  // // var length = data.length;
  // console.log(data);
  // console.log(JSON.parse(data));
  console.log(data[0].name);
  res.render('file/openvpn', { user: req.user, data: data });
}); 


module.exports = router;