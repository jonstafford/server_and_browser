require 'socket'      # Sockets are in standard library
require 'io/console'
require 'json'

hostname = 'localhost'
port = 2000



puts "Which type of request"
puts "1) GET"
puts "2) POST"

request_type = 0

while (![1, 2].include? request_type)
  char = STDIN.getch
  if char == "\u0003"
    puts "Exiting..." 
    exit(1)
  end
  request_type = char.to_i
end

get = request_type == 1

req = []

if (get)
  req[0] = "GET /index.html"
else
  req[0] = "POST /raid"
  
  puts "You're registering for a viking raid"
  puts "Name?"
  name = gets.chomp
  puts "Email?"
  email = gets.chomp
  
  form_data = {:viking => {:name => name, :email => email}}
  
  encoded = form_data.to_json
  
  req[1] = "Content-Type: application/x-www-form-urlencoded"
  req[2] = "Content-Length: " + encoded.length.to_s
  req[3] = ""
  req[4] = encoded
end

s = TCPSocket.open(hostname, port)

req[0] += " HTTP/1.1"

s.print req.join "\r\n" 


puts "request sent, waiting for response"

response = s.read

puts "response #{response}"

#while line = s.gets   # Read lines from the socket
#  puts line.chop      # And print with platform line terminator
#end
s.close               # Close the socket when done

puts "socket closed, exiting"