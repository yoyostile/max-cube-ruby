require 'byebug'
require 'ipaddr'
require 'base64'

require "max/discovery"
require "max/udp_client"
require "max/telnet_client"

require "max/cube/version"
require "max/cube/parser"
require "max/cube/client"

module Max
  module Cube
    PORT = 23272
    TELNET_PORT = 62910
  end
end
