require 'net/telnet'

class Max::TelnetClient

  def initialize(addr, port)
    @addr = addr
    @port = port
  end

  def start
    resp = []
    client.cmd('') { |c| resp << c.split("\n"); }
    resp.flatten
  rescue Net::ReadTimeout
    resp.flatten
  end

  def send_message(message)
    resp = []
    client.cmd(message) { |c| resp << c; }
    resp
  rescue Net::ReadTimeout
    resp
  end

  def close
    client.cmd('q:\r\n')
    client.close
    @client = nil
  end

  private

  def client
    @client ||= Net::Telnet::new(
      "Host" => @addr,
      "Port" => @port,
      "Timeout" => 1
    )
  end
end
