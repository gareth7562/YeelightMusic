require 'socket'

PORT = 55440


@clients= []

def set_rgb(rgb_value, effect, duration)
  cmd = "{\"id\":3,\"method\":\"set_rgb\",\"params\":[#{rgb_value},\"#{effect}\",#{duration}]}\r\n"
  return cmd
end

def set_power(power, effect, duration)
  cmd = "{\"id\":6,\"method\":\"set_power\",\"params\":[\"#{power}\",\"#{effect}\",#{duration}]}\r\n"
  return cmd
end


@socket = TCPServer.new('0.0.0.0', PORT)
@i = 0
@command_socket = TCPServer.new('0.0.0.0', 1337)
@commander = []

        def handle_connection


          red = 16711680
          blue = 255
          green = 65280
          default_color = 1

          puts "New client! #{@clients[@i]}"


          for c in @clients do



          #puts command

          end
          c.puts(set_power("on", "smooth", 1))

          loop do

          command = @commander.gets(1000)
          if(command.strip == "default") then
          c.puts(set_rgb(default_color, "smooth", 1))
          end
          if(command.strip == "r") then
          c.puts(set_rgb(red, "smooth", 1))
          end
          if(command.strip == "g") then
          c.puts(set_rgb(green, "smooth", 1))
          end

          if(command.strip == "b") then
          c.puts(set_rgb(blue, "smooth", 1))
          end
          end
          end


def handle_commander(commander_client)
  puts 'Commander Connected!'

end

        puts "Server Listening on #{PORT}. Press CTRL+C to cancel."
        puts "Commander on port 1337 run node myapp.js <server ip> track.mp3 to play a track via this server"
        @commander = @command_socket.accept
        Thread.new{ handle_commander(@commander) }
        loop do

          @clients[@i] = @socket.accept

          Thread.new { handle_connection() }
          @i = @i + 1
        end
