require "absa-h2h/version"
require "yaml"

require 'absa-h2h/helpers'
require 'absa-h2h/transmission'

module Absa
  module H2h
    
    def self.build(json)
      th = Transmission::Header.new(json[:transmission_header])
      th
    end
    
  end
end
