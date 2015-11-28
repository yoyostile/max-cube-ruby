module Max
  module Cube
    class Parser
      UDP_MESSAGE_TYPES = %w(I N h)
      MESSAGE_TYPES = %w(C L)

      def initialize
      end

      def parse(message)
        body = {}
        type, payload = message.split(':')
        if MESSAGE_TYPES.include?(type)
          body.merge! send("parse_#{type.downcase}", payload)
        end
        body
      end

      def udp_parse(message)
        body = parse_udp_header(message)
        type = body[:req_type]
        if UDP_MESSAGE_TYPES.include?(type)
          payload = send("parse_udp_#{type.downcase}", body[:payload])
          body[:payload] = payload
        end
        body
      end

      private

      def parse_l(payload)
        payload = Base64.decode64(payload)
        hash = {
          submessage_length:    payload[0].unpack('C')[0],
          rf_address:           payload[1..3].unpack('H*')[0],
          unknown:              payload[4],
          flags:                payload[5..6]
        }
        if hash[:submessage_length] > 6
          hash.merge!({
            valve_position:     payload[7].unpack('C'),
            temperature:        payload[8].unpack('C')[0]/2,
            date_until:         payload[9..10].unpack('C'),
            time_until:         payload[11].unpack('C')
          })
        end
        if hash[:submessage_length] > 11
          hash.merge!({
            actual_temperature: payload[12].unpack('C')[0]/2
          })
        end
        hash
      end

      def parse_c(payload)
        address, payload = payload.split(',')
        payload = Base64.decode64(payload)
        decoded = {
          data_length:  payload[0].unpack('C')[0],
          rf_address:   payload[1..3].unpack('H*')[0],
          device_type:  payload[4].unpack('C')[0],
          room_id:      payload[5].unpack('C')[0],
          fw_version:   payload[6].unpack('H*')[0],
          test_result:  payload[7].unpack('C')[0],
          sn:           payload[8..17]
        }
        if decoded[:device_type] == 2
          decoded.merge!({
            comfort_temperature:    payload[18].unpack('C')[0]/2,
            eco_temperature:        payload[19].unpack('C')[0]/2,
            max_sp_temperature:     payload[20].unpack('C')[0]/2,
            min_sp_temperature:     payload[21].unpack('C')[0]/2,
            temperature_offset:     payload[22].unpack('C')[0]/2,
            window_open_temperature:payload[23].unpack('C')[0]/2,
            window_open_duration:   payload[24].unpack('C')[0]*5
          })
        end
        if decoded[:device_type] == 3
          decoded.merge!({
            comfort_temperature:    payload[18].unpack('C')[0]/2,
            eco_temperature:        payload[19].unpack('C')[0]/2,
            max_sp_temperature:     payload[20].unpack('C')[0]/2,
            min_sp_temperature:     payload[21].unpack('C')[0]/2
          })
        end
        { address => decoded }
      end

      def parse_udp_header(message)
        {
          name:     message[0..7],
          sn:       message[8..17],
          req_id:   message[18],
          req_type: message[19],
          payload:  message[20..-1]
        }
      end

      def parse_udp_i(payload)
        {
          rf_address: payload[0..2].unpack('H*')[0],
          fw_version: payload[2..-1]
        }
      end

      def parse_udp_n(payload)
        {
          ip:             IPAddr.ntop(payload[0..3]),
          gateway:        IPAddr.ntop(payload[4..7]),
          netmask:        IPAddr.ntop(payload[8..11]),
          dns_primary:    IPAddr.ntop(payload[12..15]),
          dns_secondary:  IPAddr.ntop(payload[16..19])
        }
      end

      def parse_udp_h(payload)
        {
          port:       payload[0..1].unpack('n')[0],
          path:       payload[2..-1].split(',')
        }
      end
    end
  end
end
