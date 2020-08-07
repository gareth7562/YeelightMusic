YeeLightMusic
-------------

my attempt at a Yeelight Music Server in Ruby and NodeJS client for playing mp3 files. This will control the lights on a yeelight without capping the amount of requests

Run server with:

*ruby server.rb*

Then play tracks on any device via the server ip i.e.

*node myapp.js 192.168.1.56 "tracks/drums.mp3"*

Also works with youtube urls i.e. 

*node myapp.js 192.168.1.56 \<youtube url>*
  
replace IP with your own server IP
I had issues with running the server on localhost if that doesnt work, try using a seperate computer on the same network to run the server.

the IPs for the bulbs must be set with the ips array variable in myapp.js

mine are set to 192.168.1.55 and 192.168.1.59 
you can get these from the yeelight app 

only tested with 2 bulbs and it is setup to vary between 2 colors although it would be easy to add more


make sure to install the relevant node libraries with npm
These are
* yeelight-platform
* speaker
* create-music-stream
* music-beat-detector
* color

you can now specify custom colors in config.txt in css style, defaults set to blue and green. Only supports 2 different colors
