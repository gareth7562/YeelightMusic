YeeLightMusic


my attempt at a Yeelight Music Server in Ruby and NodeJS client for playing mp3 files. This will control the lights on a yeelight without capping the amount of requests

Run server with:

ruby server.rb

Then play tracks on any device via the server ip i.e.

node myapp.js <server ip> "tracks/chill.mp3"
  
I had issues with running the server on localhost if that doesnt work, try using a seperate computer on the same network to run the server.

the IPs for the bulbs must be set with the ips array variable in myapp.js

mine are set to 192.168.1.55 and 192.168.1.59 
you can get these from the yeelight app
