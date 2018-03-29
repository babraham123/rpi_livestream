#!/usr/bin/env node

// Nodejs wifi sign in server
// npm install express --save
// npm install body-parser --save

const express = require('express');
const bodyParser = require('body-parser');
const child_process = require('child_process');

// make sure to check the name of your wifi device (wlan0 in most cases)
const getNetworksCmd = 'sudo iw dev wlan0 scan ap-force | egrep "SSID:"';
const ssidRows = child_process.execSync(getNetworksCmd).toString().split('\n');
var ssids = [];
for (i = 0; i < ssidRows.length; i++) { 
    var ssidName = ssidRows[i].substring("\tSSID: ".length);
    if (ssidName && ssidName.length < 60) {
        ssids.push(ssidName);
    }
}
console.log(ssids);

// Create application/x-www-form-urlencoded parser
const urlencodedParser = bodyParser.urlencoded({ extended: false });

const app = express();
app.use(express.static('/home/pi/public'));

app.post('/signin_post', urlencodedParser, function (req, res) {
    response = {
        ssid:req.body.ssid,
        password:req.body.password
    };
    const addWifiCmd = 'sudo /usr/bin/addwificreds "' + response.ssid + '" "' + response.password + '"';
    console.log(addWifiCmd);

    // add ssid to wpa_supplicant.conf
    child_process.exec(addWifiCmd, (error, stdout, stderr) => {
        if (error) {
            console.log('stdout: ' + stdout);
            console.log('stderr: ' + stderr);
            console.error('exec error: ' + error);
            res.sendFile('/home/pi/public/index.html');
        } else {
            console.log('stdout: ' + stdout);
            console.log('stderr: ' + stderr);
            res.sendFile('/home/pi/public/response.html');
            setTimeout(
                function() {
                    process.exit();
                }, 5000);
        }
    });
})

const server = app.listen(80, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Sign-in server listening at http://%s:%s", host, port);
})
