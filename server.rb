require 'socket'
PORT = 55440

@lock = Mutex.new

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
@threads = Array.new
@new_client_list = Array.new
$commander_connections = 0


def resetConnection(addr)
    puts "[#{Time.now}] Client #{addr} disconnected."
    if(@clientHash[addr] != nil and !@clientHash[addr].closed?) then
    @clientHash[addr].close
    @clientHash[addr] = nil
    @clientHash.delete_if { |k, v| v == nil }
    @command = ""
    @new_client_list.delete(addr)
    @new_client_list.compact
    printConnectedDevices
    end

end

def printConnectedDevices 
  
  puts "#{@new_client_list.count} devices connected."
end
  
trap "SIGINT" do
  puts "Exiting"

exit 130
end
def sendToClient(command)
    begin
      @new_client_list.dup.each do |addr|
        if @clientHash[addr] != nil and !@clientHash[addr].closed? then
      @clientHash[addr].send(command, 0)
  end      
rescue Errno::EPIPE
    puts "#{[Time.now]} Broken connection for #{addr}"
    if(addr != nil)
    resetConnection(addr) 
   end
rescue Errno::ECONNRESET => e 
    if(addr != nil)
    resetConnection(addr)
    puts "#{[Time.now]} Connection reset for #{addr} #{e}"         
    end
rescue IOError
    if(addr != nil)
    resetConnection(addr)
    puts "#{[Time.now]} Error sending data to #{addr}"
    end
end
end
end


def handle_connection

prevCommand = nil
response_time = 0 #ms response from bulb
transition_effect = "sudden"
loop do

  if @new_client_list.count == 0  
    then 
    @clientHash.clear
    return
  end
begin

  if (@commander != nil) then
@command = @commander.gets(15)
end
rescue Errno::ECONNRESET => e

  puts "#{[Time.now]} Commander connection reset."
  printConnectedDevices
  $commander_connections = 0
  @new_client_list.each do |addr|
    resetConnection(addr) 
    return
  end           
end

begin
@command = @command.chomp
rescue NoMethodError => e
  command = "disconnect"
end
if (@command == "disconnect") then

  @command = ""
  $commander_connections = 0
  puts "#{[Time.now]} Client disconnected normally"
  @clientHash.each do |addr, key|
  resetConnection(addr)
  end
  num_clients = 0
end


if @command != nil and @command.start_with? "c" then
  tokens = @command.split(" ")

  sendToClient(set_rgb(tokens[1], transition_effect, response_time))
end

  prevCommand = @command
end
end

def handle_commander

if $commander_connections == 0
@commander = @command_socket.accept
end
$commander_connections = $commander_connections + 1
end
puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"


  
  
new_client = nil
num = 0
  
  loop do
  new_client = socket.accept
@threads <<  Thread.new(new_client) do |n|
     handle_commander
     sock_domain, remote_port, remote_hostname, remote_ip = n.peeraddr(false)

  
  puts "#{[Time.now]} Client #{remote_ip} connected"
  n.send(set_bright(50, "smooth", 500), 0);
  if @clientHash[remote_ip] != nil and !@clientHash[remote_ip].closed? then
  @new_client_list.delete(remote_ip) 
  @clientHash[remote_ip].close
  end
  
  @clientHash[remote_ip] = n
  @new_client_list.push(remote_ip)
  @num_clients = @new_client_list.count
  printConnectedDevices
  handle_connection
  end 
  end


