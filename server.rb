require 'socket'
require 'thread'
PORT = 55440
@clients = []
def set_rgb(rgb_value, effect, duration)
cmd = "{\"id\":3,\"method\":\"set_rgb\",\"params\":[#{rgb_value},\"#{effect}\",#{duration}]}\r\n"
return cmd
end
def set_power(power, effect, duration)
cmd = "{\"id\":6,\"method\":\"set_power\",\"params\":[\"#{power}\",\"#{effect}\",#{duration}]}\r\n"
return cmd
end
@socket = TCPServer.new('0.0.0.0', PORT)
@command_socket = TCPServer.new('0.0.0.0', 1337)
@clientArray = Array.new
@command = "" 


def resetConnection

@clientArray.each do |client |
  client.close
  client = nil
  end
  @clientArray.clear

end

  
trap "SIGINT" do
  puts "Exiting"
  resetConnection

if @t != nil then
@t.kill
end
if @t2 != nil then
@t2.kill
end
exit 130
end

def sendToClients(command)

@clientArray.each do |client |
    client.send(command, 0)

  end
end



def handle_connection(index)

red = 16711680
blue = 255
green = 65280
default_color = 0
puts "New client! #{[index]}"

loop do

  begin

if (@commander != nil) then
@command = @commander.gets(100)

end
rescue Errno::ECONNRESET => e

resetConnection

end


if (@command != nil) then
if (@command.strip == "disconnect") then

  puts "Client disconnected, please reconnect to server"
  @command = ""
  resetConnection

end

if (@command.strip == "default") then

  sendToClients(set_rgb(default_color, "smooth", 100))

end

if (@command.strip == "r") then

  sendToClients(set_rgb(red, "smooth", 100))

end

if (@command.strip == "g") then

  sendToClients(set_rgb(green, "smooth", 100))

end

if (@command.strip == "b") then
  sendToClients(set_rgb(blue, "smooth", 100))

end
end
end
end

def handle_commander

@commander = @command_socket.accept
end

puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"

loop do

  @clientArray.push(@socket.accept)

Thread.new {
  handle_commander
}
@t = Thread.new {
  handle_connection(@clientArray.size);
}

end


