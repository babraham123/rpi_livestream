#!/usr/bin/env node

// Nodejs wifi sign in server
// npm install express --save
// npm install body-parser --save

const express = require('express');
const bodyParser = require('body-parser');
const child_process = require('child_process');

const app = express();
app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded

app.use(express.static('/home/pi/public'));

app.get('/ssids', function(req, res) {
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
    res.send(JSON.stringify({'ssids': ssids}));
})

app.post('/signin', function (req, res) {
    const addWifiCmd = 'sudo /usr/bin/addwificreds "' + req.body.ssid + '" "' + req.body.password + '"';
    console.log(addWifiCmd);

    res.sendFile('/home/pi/public/response.html', {}, function (err) {
        if (err) {
            console.log('err: ' + err);
        }
        // add ssid to wpa_supplicant.conf
        child_process.exec(addWifiCmd, (error, stdout, stderr) => {
            if (error) {
                console.log('stdout: ' + stdout);
                console.log('stderr: ' + stderr);
                console.error('exec error: ' + error);
            } else {
                console.log('stdout: ' + stdout);
                console.log('stderr: ' + stderr);
                if (stdout.includes("Starting payload")) {
                    process.exit();
                }
            }
        });
    });
})

const server = app.listen(80, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("Sign-in server listening at http://%s:%s", host, port);
})

