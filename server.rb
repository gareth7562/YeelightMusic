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
@thread_pool = Array.new
@new_client_list = Array.new
@commander_thread = Array.new 
@disconnected = Array.new


@handler_created = false
@logged_in = false

def resetConnection(addr)


    if addr != nil then

    puts "[#{Time.now}] Client #{addr} disconnected."
    if(@clientHash[addr] != nil and !@clientHash[addr].closed?) then
    @clientHash[addr].close
    @clientHash[addr] = nil
    @clientHash.delete_if { |k, v| v == nil }
    @command = ""
    Thread.list.each do |t|
    if t.name == addr then
      @thread_pool.push(t)
end
end


    end
    end
    end

def printConnectedDevices 
 
  puts "#{@new_client_list.count} devices connected."
end
  
trap "SIGINT" do
  puts "Exiting"

exit 130
end
def sendToClient(command, addr)
    begin
      
      if @clientHash[addr] != nil and !@clientHash[addr].closed? then
      
        @clientHash[addr].write(command)
      end

rescue Errno::EPIPE
    puts "#{[Time.now]} Broken connection for #{addr}"
    if !@disconnected.include? addr then
    @disconnected.push(addr) 
    end
rescue Errno::ECONNRESET => e 
    puts "#{[Time.now]} Connection reset for #{addr} #{e}"  
    if !@disconnected.include? addr then 
    @disconnected.push(addr)
    end
rescue IOError
    if !@disconnected.include? addr then
    @disconnected.push(addr)
    end
    puts "#{[Time.now]} Error sending data to #{addr}"
end


    @disconnected.each do |addr| 
    resetConnection(addr)

end
 
 @disconnected.clear


end

def handle_connection

prevCommand = nil
response_time = 0 #ms response from bulb
transition_effect = "sudden"

loop do
  if @new_client_list.count == 0 then 

    commander = nil
    end
begin
@command = @command.chomp
rescue NoMethodError => e
  command = "disconnect"
if (@command == "disconnect") then

  @command = ""
  puts "#{[Time.now]} Client disconnected normally"
  @clientHash.each do |addr, key|
  if !@disconnected.include? addr then
  @disconnected.push(addr)
  @num_clients = 0
  return
end
end
end
end
begin
  if (@commander != nil and @logged_in) then
  @command = @commander.gets(15)
   
  end
  rescue Errno::ECONNRESET => e
    puts "#{[Time.now]} Commander connection reset."


  @commander_thread.each do |ct|
  ct.exit
  end
  @logged_in = false
  @new_client_list.each do |addr|
    Thread.list.each do |t|
      if t.name == addr then
    @thread_pool.push(t)
      end
    end

    resetConnection(addr)
    end
  @new_client_list.clear
end

if @command != nil and @command.start_with? "c" then
  tokens = @command.split(" ")
  @new_client_list.each do |addr|
  sendToClient(set_rgb(tokens[1], transition_effect, response_time), addr)

    end

  end
end
end

def handle_commander
@commander_thread << Thread.new {
       
        Thread.current.name = "commander_thread"
        login_socket = @command_socket.accept
        if @logged_in == false then
          if login_socket.gets(16).chomp == 'connect_string' then
        @logged_in = true
        @commander = login_socket
          else p "Invalid Client Connected to command socket"
        end
        end
}

end

puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"


new_client = nil
socket.listen 128
loop do


    @thread_pool.each do |t|
      t.exit
    end

    @thread_pool.clear


  new_client = socket.accept
  new_client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
   
  @threads << Thread.new(new_client) { |n| 
     sock_domain, remote_port, remote_hostname, remote_ip = n.peeraddr(false)
  puts "#{[Time.now]} Client #{remote_ip} connected"
  n.send(set_bright(50, "smooth", 500), 0)
  if @clientHash[remote_ip] != nil and !@clientHash[remote_ip].closed? then
  @new_client_list.delete(remote_ip) 
  @clientHash[remote_ip].close
  end
  @clientHash[remote_ip] = n
  @new_client_list.push(remote_ip)
  @num_clients = @new_client_list.count
  handle_commander
    
  puts "Active threads: #{Thread.list.count}"
  Thread.current.name = remote_ip
  
  client_threads = Thread.list.count{ |x| x.name != "cmd_thread" and 
        x != Thread.main and x != 'commander_thread'}
     
  puts "Num client threads: #{client_threads}"
  printConnectedDevices
if  !@handler_created then
  Thread.new {

     Thread.current.name ||= "cmd_thread"
     @handler_created = true
     



     handle_connection
  }


end

      
      @cmd_threads = Thread.list.count { |x| x.name ==  "cmd_thread"}
      puts "Command threads: #{@cmd_threads}"
  }
  end

