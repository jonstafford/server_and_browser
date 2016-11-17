require 'socket'               # Get sockets from stdlib
require 'json'

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever
  client = server.accept       # Wait for a client to connect
  
  puts "client connected!"
  
  request = nil
  
  # From http://ruby-doc.org/core-2.3.0/IO.html#method-i-read_nonblock
  # emulates blocking read (readpartial).
  begin
    request = client.read_nonblock(256) # not great
  rescue IO::WaitReadable
    IO.select([client])
    retry
  end
  
  # puts "received request #{request}"
  
  lines = request.split /\r?\n/
  
  matches = /^([A-Z]+)\s+(\S+)\s+(\S+)/.match lines[0]
  
  if matches.nil?
    matches = ["", "", "", ""]
  end
  
  verb = matches[1]
  path = matches[2]
  version = matches[3]
  
  status = ""
  content = ""
  if ("GET" == verb && path == "/index.html")
    status = "200 OK"
    File.open("index.html", "r") do |f|
      content = f.read
    end
  elsif ("POST" == verb && path == "/raid")
    
    # The instructions say you'll need the content length, but I can't see why
    length = 0
    lines.each do |line|
      length_matches = line.match(/^Content-Length:\s+(\d+)/)
      if (!length_matches.nil?)
        length = length_matches[1]
        break
      end
    end
    
   
    # Note: Use a non-capturing group to avoid captured group being returned
    # in addition to strings either side of the split.
    body = request.split(/(?:\r?\n){2}/, 2)[1]
    
    params = JSON.parse(body)
      
    status = "200 OK"
    File.open("thanks.html", "r") do |f|
      content = f.read
    end
      
    v = params["viking"]
    name = v["name"]
    email = v["email"]
    
    insert = "<li>Name: #{name}</li>" + "\n" + "<li>Email: #{email}</li>"
    
    content.gsub!("<%= yield %>", insert)
  else
    status = "400 Bad Request"
    content = ""
  end
  
  lines = []
  lines[lines.length] = version + " " + status # Initial line
  lines[lines.length] = "Server: simple_server/0.1" # Headers
  lines[lines.length] = "Content-Type: text/html"
  lines[lines.length] = "Content-Length: " + content.length.to_s
  lines[lines.length] = "" # Blank line before body
  lines[lines.length] = content
  response = lines.join "\r\n"
  
  client.print response
  
  client.close                 # Disconnect from the client
}