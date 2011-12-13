require "absa-h2h/version"
require "yaml"

require 'absa-h2h/helpers'
require 'absa-h2h/transmission'

module Absa
  module H2h
    
    def self.build(options = {})
      header = Transmission::Header.new(options[:transmission_header])
      trailer = Transmission::Header.new(options[:transmission_header])
    end
    
    def self.write_file!(header, trailer, destination)
      File.open(destination, 'w') do |f| 
        f.write(header)
        f.write(trailer) 
      end
    end
    
  end
end
