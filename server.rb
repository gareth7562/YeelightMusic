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
@reset = false
@commander = nil


def resetConnection(index)


  @clientArray.each do |client|
  if(client != @clientArray[index])
    client.close
    @clientArray.delete(client)
  end
  @command = ""

end
end
  
trap "SIGINT" do
  puts "Exiting"

if @t != nil then
@t.kill
end
if @t2 != nil then
@t2.kill
end
exit 130
end

def sendToClients(command)

@clientArray.each do |client|
    
    begin
    if !client.closed? then
    client.send(command, 0)
    end
rescue Errno::EPIPE
    client.close
    @clientArray.delete(client)

rescue Errno::ECONNRESET 
    client.close
    @clientArray.delete(client)
    
    
  end
    if !client.closed? then
    client.send(command, 0)
    end
  end

end

def handle_connection(index)

red = 16711680
blue = 255
green = 65280
prevCommand = nil
response_time = 0 #ms response from bulb
transition_effect = "sudden"

default_color = 255 
loop do

begin
if (@commander != nil) then
@command = @commander.gets(5)
end
rescue Errno::ECONNRESET => e
  resetConnection(index)

end

begin
@command = @command.chomp
rescue NoMethodError => e
  command = "disconnect"
end
if (@command == "disconnect") then

  puts "Client disconnected, please reconnect to server"
  @command = ""
  resetConnection(index)
end




if (@command == "r" && prevCommand != "r") then

  sendToClients(set_rgb(red, transition_effect, response_time))

end

if (@command == "g" && prevCommand != "g") then

  sendToClients(set_rgb(green, transition_effect, response_time))

end

if (@command == "b" && prevCommand != "b") then
  sendToClients(set_rgb(blue, transition_effect, response_time))

end

  prevCommand = @command
end
end

def handle_commander

@commander = @command_socket.accept
@commander.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
end

puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"

loop do

  new_client = @socket.accept
  sock_domain, remote_port, remote_hostname, remote_ip = new_client.peeraddr
  puts "New Client #{remote_ip}"  
  new_client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  @clientArray.push(new_client)

Thread.new {
  handle_commander
}
@t = Thread.new {
  index = 0
  if @clientArray.size > 0 then
    index = @clientArray.size - 1
  end
  handle_connection(index);
}

end


