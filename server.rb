require 'socket'
PORT = 55440
@clients = []
def set_rgb(rgb_value, effect, duration)
cmd = "{\"id\":3,\"method\":\"set_rgb\",\"params\":[#{rgb_value},\"#{effect}\",#{duration}]}\r\n"
return cmd
end

def set_bright(brightness, effect, duration)
cmd = "{\"id\":5,\"method\":\"set_bright\",\"params\":[#{brightness},\"#{effect}\",#{duration}]}\r\n"
return cmd
end


def set_power(power, effect, duration)
cmd = "{\"id\":6,\"method\":\"set_power\",\"params\":[\"#{power}\",\"#{effect}\",#{duration}]}\r\n"
return cmd
end
socket = TCPServer.new('0.0.0.0', PORT)
@command_socket = TCPServer.new('0.0.0.0', 1337)
@clientHash = Hash.new
@command = "" 
@commander = nil
@num_clients = 0
@iplist = Array.new

def resetConnection(addr)


    @clientHash[addr].close
    @command = ""
    @iplist.delete(addr)
    @t.kill
    @t2.kill

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


def sendToClient(command)

 @iplist.each do |addr| 
    begin
      if @clientHash[addr] != nil then
      @clientHash[addr].send(command, 0)
    end
rescue Errno::EPIPE
    @clientHash[addr].close
    @iplist.delete(addr)

rescue Errno::ECONNRESET 
    @clientHash[addr].close
   
rescue IOError
    @clientHash[addr].close
    puts "#{[Time.now]} Error sending data to #{addr}"
    @iplist.delete(addr)

end
    
end

end




def handle_connection(ip)

red = 16711680
blue = 255
green = 65280
prevCommand = nil
response_time = 0 #ms response from bulb
transition_effect = "sudden"


loop do
begin
  if (@commander != nil && @iplist.length > 0) then
@command = @commander.gets(15)
else
  break
end
rescue Errno::ECONNRESET => e

  puts "#{[Time.now]} Client disconnected. (reset)"
  @iplist.each do |addr|                                                                                                  
    resetConnection(addr)                                                                                                   
  end           
end

begin
@command = @command.chomp
rescue NoMethodError => e
  command = "disconnect"
end
if (@command == "disconnect") then

  @command = ""
  puts "#{[Time.now]} Client disconnected normally"
  @iplist.each do |addr|
  resetConnection(addr)
  end
end



if (@command == "r" && prevCommand != "r") then

  sendToClient(set_rgb(red, transition_effect, response_time))
end

if (@command == "g" && prevCommand != "g") then

 sendToClient(set_rgb(green, transition_effect, response_time))

end

if (@command == "b" && prevCommand != "b") then
 sendToClient(set_rgb(blue, transition_effect, response_time))

end

  prevCommand = @command
end
end

def handle_commander
loop do
@commander = @command_socket.accept
#@commander.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
end
end
puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"


  
  
@t2 = Thread.new {
  handle_commander
}

loop do
new_client = socket.accept

@t = Thread.new {

    
  sock_domain, remote_port, remote_hostname, remote_ip = new_client.peeraddr
  puts "#{[Time.now]} Client #{remote_ip} connected"
  #new_client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  new_client.send(set_bright(50, "smooth", 500), 0);
  if(@clientHash[remote_ip] != nil)
  @clientHash[remote_ip].close
  @iplist.delete(remote_ip)
  end
  @clientHash[remote_ip] = new_client
  @num_clients = @num_clients + 1;
  @iplist.push(remote_ip)
  handle_connection(remote_ip);
}

end
