var fs = require('fs');

module.exports = function() {
        var result = data_out(); 
        return result;
}
function data_out(){
    var data = fs.readFileSync('test.txt','utf8');
    var data1 = data.split('\n');
    var array = new Array();
    var tmp ;
    var obj = new Object;
    for ( i in data1 ){
        var tmp ;
        tmp1 = data1[i].split(',');
        console.log("id",tmp1[0]);
        console.log("name",tmp1[1]);
        obj.name = tmp1[0];
        obj.ip = tmp1[1];
        console.log(obj);
        array.push(JSON.parse(JSON.stringify(obj)));
        console.log(array);
    }
    return array;
}


