// Nodejs wifi sign in server
// npm install express --save
// npm install body-parser --save

const express = require('express');
const bodyParser = require('body-parser');
const child_process = require('child_process');

const ssids = child_process.execSync('iw dev "$wifidev" scan ap-force | egrep "^BSS|SSID:"').split(',');

// Create application/x-www-form-urlencoded parser
const urlencodedParser = bodyParser.urlencoded({ extended: false });

const app = express();
app.use(express.static('public'));

// app.get('/index.html', function (req, res) {
//    res.sendFile( __dirname + "/" + "public/index.html" );
// })

app.post('/signin_post', urlencodedParser, function (req, res) {
    response = {
        ssid:req.body.ssid,
        password:req.body.password
    };
    res.sendFile( __dirname + "/" + "public/response.html" );

    // add ssid to wpa_supplicant.conf
    child_process.exec('/usr/bin/addwificreds ${response.ssid} ${response.password}', (error, stdout, stderr) => {
        if(error) {
            console.error('exec error: ${error}');
        }
        console.log('stdout: ${stdout}');
        console.log('stderr: ${stderr}');
        exit(0);
    });
})

const server = app.listen(80, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Example app listening at http://%s:%s", host, port);
})

