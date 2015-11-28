require 'socket'

class Max::Discovery
  DISCOVERY_MESSAGE = 'eQ3Max*.**********I'
  class << self

    def find_cube!
      response = send_message '<broadcast>', Max::Cube::PORT, DISCOVERY_MESSAGE
      resp = Max::Cube::Parser.new.udp_parse response[0]
      pp resp
      [ resp[:sn], response[1][2] ]
    end

    private

    def send_message(addr, port, message)
      puts "Sending message: #{message}"
      puts "Sending to: #{addr}:#{port}"
      socket = new_broadcast_socket()
      socket.bind('0.0.0.0', port)
      socket.send(message, 0, addr, port)
      socket.recvfrom(1024)
      response = socket.recvfrom(1024)
      socket.close
      response
    end

    def new_broadcast_socket
      UDPSocket.new.tap{ |sock| sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) }
    end
  end
end
