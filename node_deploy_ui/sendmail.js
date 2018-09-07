var nodemailer = require('nodemailer');
var mailto = 'jasson.hsu@gmail.com'
var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'jasson.hsu.vpn@gmail.com',
    pass: 'openstack@ideas!@#'
  }
});

var mailOptions = {
  from: 'jasson.hsu.vpn@gmail.com',
  to: mailto,
  subject: 'Sending Email using Node.js',
  text: 'That was easy!',
  attachments: [
    {
      filename: 'openvpn',
      path : 'test.txt'
    }
  ]
};

transporter.sendMail(mailOptions, function(error, info){
  if (error) {
    console.log(error);
  } else {
    console.log('Email sent: ' + info.response);
  }
});