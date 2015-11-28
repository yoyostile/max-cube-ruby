module Max
  module Cube
    class Client
      attr_reader :devices

      def initialize(addr, sn)
        @ip = addr
        @sn = sn
        @devices = start_telnet
      end

      def start_telnet
        response = telnet_client.start()
        response.inject({}) do |memo,msg|
          memo.merge!(parser.parse(msg))
        end.keep_if{ |f| !f.empty? }
      end

      def get_network
        res = udp_send message_with_suffix('N')
        parser.udp_parse res[0]
      end

      def get_url
        res = udp_send message_with_suffix('h')
        parser.udp_parse res[0]
      end

      # def get_devices
      #   @devices.keys.inject({}) do |memo, k|
      #     res = telnet_send 'c:' + k + '\r\n'
      #     memo.merge!(parser.parse(res[0]))
      #     memo
      #   end
      # end

      def get_device_list
        res = telnet_send 'l:\r\n'
        parser.parse res[0]
      end

      private
      def parser
        @parser ||= Parser.new
      end

      def telnet_send(msg)
        telnet_client.send_message(msg)
      end

      def udp_send(msg)
        Max::UDPClient.new.send_message @ip, Max::Cube::PORT, msg
      end

      def message_with_suffix(suffix)
        "eQ3Max*\0#{@sn}#{suffix}"
      end

      def telnet_client
        @telnet_client ||= Max::TelnetClient.new(@ip, Max::Cube::TELNET_PORT)
      end
    end
  end
end
