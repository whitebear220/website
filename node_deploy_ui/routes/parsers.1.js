module.exports = function(data) {
        // console.log("123" + data)
        parser_out(data);
}

function parser_out(data_in)
{
    String.prototype.trim = function (char, type) {
        if (char) {
            return this.replace(new RegExp('^\\'+char+'+|\\'+char+'+$', 'g'), '');
        }
        return this.replace(/^\s+|\s+$/g, '');
    };
    var fs = require('fs');
    var data = fs.readFileSync('conf/nodeconfig.conf', 'utf8');
    // fs.writeFileSync('output2.json', '','uft8');
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
        OPENSTACK_VER:tmp2[0],
        COUNTY:tmp2[1],
        DATE:tmp2[2],
        TIME:tmp2[3],
        CT_HOST:tmp2[4],
        CT_IP:tmp2[5],
        MANAGE_PORT:tmp2[6],
        VMLAN_PORT:tmp2[7],
        PUBLIC_PORT:tmp2[8],
        MANAGE_IP:tmp2[9],
        MANAGE_GW:tmp2[10],
        DNS:tmp2[11],
        VMLAN_IP:tmp2[12],
        EXT_NET:tmp2[13],
        EXT_GATEWA:tmp2[14],
        EXT_DNS:tmp2[15],
        EXT_START:tmp2[16],
        EXT_STOP:tmp2[17]
    }
    fs.writeFileSync('output2.json', JSON.stringify(result), 'utf8');
}