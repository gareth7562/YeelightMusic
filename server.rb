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
def handle_connection

                red = 16711680
                blue = 255
                green = 65280
                default_color = 0
                puts "New client! #{[@clients]}"
                loop do


                @command = @commander.gets(20)


                @clientArray.each do |client|

                client.send(set_power("on", "smooth", 1), 0)

                if(@command != nil) then
                if (@command.strip == "default") then
                  client.send(set_rgb(default_color, "smooth", 1), 0)
                end
                if (@command.strip == "r") then
                  client.send(set_rgb(red, "smooth", 1), 0)
                end
                if (@command.strip == "g") then
                  client.send(set_rgb(green, "smooth", 1), 0)
                end
                if (@command.strip == "b") then
                  client.send(set_rgb(blue, "smooth", 1), 0)
                end
                end
                end

end
end


def handle_commander
        @commander = @command_socket.accept

end

puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"


Thread.new {  handle_commander }


i = 0
loop do
                @clientArray[i] = @socket.accept
                Thread.new {
                  handle_connection
        }
        i = i+1
        end
