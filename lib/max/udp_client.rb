class Max::UDPClient

  def initialize
  end

  def send_message(addr, port, message)
    puts "Sending message: #{message}"
    puts "Sending to: #{addr}:#{port}"
    socket = new_socket()
    socket.bind('0.0.0.0', port)
    socket.send(message, 0, addr, port)
    response = socket.recvfrom(1024)
    socket.close
    response
  end

  private

  def new_socket
    UDPSocket.new
  end
end
