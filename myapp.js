const fs = require('fs')
const YeeDevice = require('yeelight-platform').Device
const Speaker = require('speaker')
const createMusicStream = require('create-music-stream') //read this https://github.com/chrvadala/create-music-stream#faq
const {
    MusicBeatDetector,
    MusicBeatScheduler,
    MusicGraph
} = require('music-beat-detector')
const getMP3Duration = require('get-mp3-duration');
var net = require('net');


const musicSource = process.argv[3] //get the first argument on cli
var color1 = 255;
var color2 = 65280;
var color3 = 16711680;
var trackLength = 0;
var peaks = 0;
var divider = 0;
const buffer = fs.readFileSync(musicSource);
const duration = getMP3Duration(buffer);

nextColor = color1;

ips = ["192.168.1.55"];
server = process.argv[2];
//ips = ["192.168.1.59", "192.168.1.55"];

device = {};
prevColor = 0;
var music_enabled = false;
var color = 1




for (var i = 0; i < ips.length; i++) {

    device[i] = new YeeDevice({
        host: ips[i],
        port: 55443
    });

    device[i].connect();


    device[i].on('deviceUpdate', (newProps) => {
        console.log(newProps)
    })


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
    });

}

var client = new net.Socket();
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


const musicGraph = new MusicGraph()

const musicBeatScheduler = new MusicBeatScheduler(pos => {
    console.log(`peak at ${pos}ms`) // your music effect goes here


    color++;

    if (color > 2) {
        color = 1;
    }
    switch (color) {
        case 1:
            client.write("r\r\n")
            break;

        case 2:
            client.write("g\r\n")
            break;

        default:


    }

});

const musicBeatDetector = new MusicBeatDetector({
    plotter: musicGraph.getPlotter(),
    scheduler: musicBeatScheduler.getScheduler(),
    sensitivity: 0.5,
});

createMusicStream(musicSource)
    .pipe(musicBeatDetector.getAnalyzer())
    .on('peak-detected', (pos, bpm) => {




        console.log(`peak-detected at ${pos}ms, detected bpm ${bpm}`)
    })
    .on('end', () => {
        fs.writeFileSync('graph.svg', musicGraph.getSVG())
        console.log('end')
    })

    .pipe(new Speaker())
    .on('open', () => {
        musicBeatScheduler.start()


    });
