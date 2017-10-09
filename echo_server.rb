require 'socket'

def parse_request(request_line)
  http_method, path_and_params, http = request_line.split(' ')
  path, params = path_and_params.split('?')
  params = params.split('&').each_with_object({}) do |pair, hash|
    key, value = pair.split('=')
    hash[key] = value
  end

  [http_method, path, params]
end

server = TCPServer.new('localhost', 3003)

loop do
  client = server.accept

  request_line = client.gets
  next unless request_line || request_line =~ /favicon/
  puts request_line

  http_method, path, params = parse_request(request_line)

  random_numbers = []
  rolls = params['rolls'].to_i
  sides = params['sides'].to_i


  rolls.times do
    random_numbers << rand(1..sides)
  end

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html"
  client.puts
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts http_method
  client.puts path
  client.puts params
  client.puts "</pre>"

  client.puts "<h1>Rolls!</h1>"
  random_numbers.each{|num| client.puts "<p>#{num}</p>"}
  client.puts "</body>"
  client.puts "</html>"

  client.close
end