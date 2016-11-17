require 'net/http'                  # The library we need
host = 'www.tutorialspoint.com'     # The web server
path = '/index.htm'                 # The file we want 

http = Net::HTTP.new(host)          # Create a connection

http.set_debug_output $stderr

#headers, body = http.get(path)      # Request the file

resp = http.get(path)

headers = resp.header
body = resp.body

puts headers
 puts "#{headers.code} #{headers.message}" 
puts body

if headers.code == "200"            # Check the status code   
  print body                        
else                                
  puts "#{headers.code} #{headers.message}" 
end