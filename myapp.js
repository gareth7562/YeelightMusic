const YeeDevice = require('yeelight-platform').Device
const Speaker = require('speaker')
var Color = require('color')

var fs = require('fs');
const createMusicStream = require('create-music-stream') //read this https://github.com/chrvadala/create-music-stream#faq
const {
    MusicBeatDetector,
    MusicBeatScheduler,
    MusicGraph
} = require('music-beat-detector')
var net = require('net');


const musicSource = process.argv[3] //get the first argument on cli
var trackLength = 0;
var peaks = 0;
var connected = false;
var color1 = 0;
var color2 = 0;

fs.readFile('config.txt', 'utf8', function(err, contents) {
    var colors = contents.split("\n");

    var clr1 = Color(colors[0]);
    var clr2 = Color(colors[1]);

    color1 = clr1.rgbNumber();
    color2 = clr2.rgbNumber();



});



server = process.argv[2];
ips = ["192.168.1.59", "192.168.1.55"];

device = {};
var color = 1;

for (var i = 0; i < ips.length; i++) {

    device[i] = new YeeDevice({
        host: ips[i],
        port: 55443
    });

    device[i].connect();


/*    device[i].on('deviceUpdate', (newProps) => {
        console.log(newProps)
    }) */


    updateLights(device[i]);

}

function updateLights(device) {
    device.on('connected', () => {
        device.sendCommand({
            id: 1337,
            method: 'set_music',
            params: [0, server, 55440]
        });

        device.sendCommand({
            id: 1337,
            method: 'set_music',
            params: [1, server, 55440]
        });

        device.sendCommand({
            id: 1337,
            method: 'set_power',
            params: ["on", "smooth", 500]
        });

        connected = true;

    });


        device.on('disconnected', () => {
          connected = false;
        });

}

var client = new net.Socket();
client.setNoDelay(true);
client.connect(1337, server, function() {
    console.log('Connected');
    client.write('Hello, server!.');
});

client.on('data', function(data) {
    console.log('Received: ' + data);
});

client.on('close', function() {
    console.log('Connection closed');
});


if (process.platform === "win32") {
  var rl = require("readline").createInterface({
    input: process.stdin,
    output: process.stdout
  });

  rl.on("SIGINT", function () {
    process.emit("SIGINT");
  });
}

process.on("SIGINT", function () {
  //graceful shutdown
  disableMusicMode();
  client.destroy()
  process.exit();

});


const musicGraph = new MusicGraph()

const musicBeatScheduler = new MusicBeatScheduler(pos => {
    //console.log(`peak at ${pos}ms`) // your music effect goes here

if(connected)
{
    if (color > 2) {
        color = 1;
    }
    switch (color) {
        case 1:
            client.write("c " + color1 + "\r\n");
            break;

        case 2:
            client.write("c " + color2 + "\r\n");
            break;

        default:
    }

    color++;

}

});


function disableMusicMode()
{
  for (var i = 0; i < ips.length; i++) {
  device[i].sendCommand({
      id: 1337,
      method: 'set_music',
      params: [0, server, 55440]
  });
}
}

const musicBeatDetector = new MusicBeatDetector({
    plotter: musicGraph.getPlotter(),
    scheduler: musicBeatScheduler.getScheduler(),
});

createMusicStream(musicSource)
    .pipe(musicBeatDetector.getAnalyzer())
    .on('peak-detected', (pos, bpm) => {



        //console.log(`peak-detected at ${pos}ms, detected bpm ${bpm}`)
    })
    .on('end', () => {

        disableMusicMode();
        console.log('end')
        client.write("disconnect\r\n")
	client.destroy()
        process.emit("SIGINT");

    })

    .pipe(new Speaker())
    .on('open', () => {
        musicBeatScheduler.start()


    });
