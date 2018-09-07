var ldap =  require("ldapjs");
var ssha = require('ssha');
var client = ldap.createClient({
  url: 'ldap://10.50.3.2:389'
});

var opts = {
  //filter: '(ou=Group)', 
  scope: 'sub',
  timeLimit: 500 ,
//   attributes: ['uid']
};

client.bind('cn=admin,dc=test,dc=com', 'openstack', function (err, res1) {

    // Add user & password
    var newDN = "uid=test328,ou=Group,dc=test,dc=com";
    var newUser = {
        cn: 'new328',
        sn: 'guy',
        uid: 'test328',
        mail: 'nguy@example.org',
        homeDirectory: '/home/test328',
        uidNumber: '45620',
        gidNumber: '0',
        objectClass: ["posixAccount", "top", "inetOrgPerson"],
        userPassword: ssha.create('')
    }
    client.add(newDN, newUser, function(err, response){
        client.unbind();
        console.log('123');
    });
  
});
