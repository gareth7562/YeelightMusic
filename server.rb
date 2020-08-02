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
@command = nil
@commander = nil

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


def handle_connection(index)

	
                red = 16711680
        	blue = 255
	        green = 65280
	        default_color = 0
		puts "New client! #{[@clients]}"
                puts index
		loop do

	                        
                @command = @commander.gets(10) #first client gets commands
                
                if(@command != nil) then 
		if (@command.chomp  == "default") then
                  
                @clientArray.each do |client|
                  client.send(set_rgb(default_color, "smooth", 200), 0)
		end
                end
		if (@command.chomp == "r") then

                @clientArray.each do |client|
                  client.send(set_rgb(red, "smooth", 200), 0)     
		end
                end
		if (@command.chomp == "g") then
                
                @clientArray.each do |client|
                  client.send(set_rgb(green, "smooth", 200), 0)
		end
                end
		if (@command.chomp == "b") then

                @clientArray.each do |client|
                  client.send(set_rgb(blue, "smooth", 200), 0)
                end
                end
		end
                end
                end
                

def handle_commander
        
        
        loop do

                @commander = @command_socket.accept
        end
end

puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"


loop do

                @clientArray.push(@socket.accept)
                
		@t = Thread.new {
                  handle_connection(@clientArray.size);
                }

end

