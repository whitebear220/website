var ldap =  require("ldapjs");
var client = ldap.createClient({
//   url: 'ldap://10.50.3.2:389'
  url: 'ldap://10.50.3.248:389'
});

var opts = {
  //filter: '(ou=Group)', 
  scope: 'sub',
  timeLimit: 500 ,
//   attributes: ['uid']
};
// var DN = 'cn=admin,dc=test,dc=com';
// var PASS = 'openstack';
// var OUDN = 'ou=Group,dc=test,dc=com';
var DN = 'cn=admin,dc=isercloud,dc=com';
var PASS = 'openstack';
var OUDN = 'ou=engineer,dc=iservcloud,dc=com';

client.bind(DN, PASS, function (err, res1) {
    client.search(OUDN, opts, function (err, res2) {
        res2.on('searchEntry', function (entry) {
            var user = entry.object;
            // console.log(user);
            var userText = JSON.stringify(user,null,2);
            var convert = JSON.parse(userText);
            console.log(convert);
        });
        
        res2.on('searchReference', function(referral) {
            console.log('referral: ' + referral.uris.join());
        });
        
        res2.on('error', function(err) {
            console.error('error: ' + err.message);
            client.unbind();
        });

        res2.on('end', function(result) {
            console.log('search status: ' + result.status);
            client.unbind();
        });
        
    });

});
