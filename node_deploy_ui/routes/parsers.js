var fs = require('fs');
String.prototype.trim = function (char, type) {
    if (char) {
        return this.replace(new RegExp('^\\'+char+'+|\\'+char+'+$', 'g'), '');
    }
    return this.replace(/^\s+|\s+$/g, '');
};

module.exports = {
        parser_in: 
        function(data){ 
            parser_in(data); 
        },
        parser_out: 
        function(data){ 
            var back = parser_out();
            return back 
        }
}

function parser_in(data_in)
{

    var data = JSON.parse(data_in);
    console.log(data);
    var length = Object.keys(data).length;
    var dic = ['openstack_ver','county','date','time','hostname','hostip','manage_port','vmlan_port',
               'public_port','manage_ip','manage_gw','dns','vmlan_ip',
               'public_net','public_gateway','public_dns','public_start','public_end'];
    var dic2 = ['OPENSTACK_VER','COUNTY','DATE','TIME','CT_HOST','CT_IP','MANAGE_PORT','VMLAN_PORT',
               'PUBLIC_PORT','MANAGE_IP','MANAGE_GW','DNS','VMLAN_IP',
               'EXT_NET','EXT_GATEWAY','EXT_DNS','EXT_START','EXT_STOP'];  
    var name, body; 
    var length = Object.keys(dic).length - 1;
    // var length = length-1;
    var result="";
    for ( i in dic ){   
        name = dic[i];
        body = data[name];
        result1 = dic2[i] + '="' + body + '"';
        if (i == length){
            result = result + result1;
        }else{
            result = result + result1 + "\n";
        }
        // if( i == length){
        //     fs.appendFile('conf/nodeconfig.conf', `${rda}` , function (err) {
        //         if (err)
        //             console.log(err);
        //         // else
        //             // console.log('writer ok');
        //     });
        // }else{
        //     fs.appendFile('conf/nodeconfig.conf', `${rda}\n` , function (err) {
        //         if (err)
        //             console.log(err);
        //         // else
        //             // console.log('writer ok');
        //     });
        // }
        
    }
    fs.writeFile('conf/nodeconfig.conf', '');
    fs.writeFileSync('conf/nodeconfig.conf', result , 'utf8');
}


function parser_out()
{
    var data = fs.readFileSync('conf/nodeconfig.conf', 'utf8');
    if ( data == "" ){
        return 0;
    }
    var tmp = data.split('\n');
    var length = Object.keys(tmp).length;
    var Obj,
        Obj2 =[],
        tmp2=[];
    for ( i in tmp ){
        var tmp1 = tmp[i].split('='); 
        var tmp4 = tmp1[1].trim('"');
        tmp2[i] = tmp4;
    };
    var result = {
        openstack_ver:tmp2[0],
        county:tmp2[1],
        date:tmp2[2],
        time:tmp2[3],
        hostname:tmp2[4],
        hostip:tmp2[5],
        manage_port:tmp2[6],
        vmlan_port:tmp2[7],
        public_port:tmp2[8],
        manage_ip:tmp2[9],
        manage_gw:tmp2[10],
        dns:tmp2[11],
        vmlan_ip:tmp2[12],
        public_net:tmp2[13],
        public_gateway:tmp2[14],
        public_dns:tmp2[15],
        public_start:tmp2[16],
        public_end:tmp2[17]
    }
    fs.writeFileSync('output2.json', JSON.stringify(result), 'utf8');
    console.log(result);
    return result;
}