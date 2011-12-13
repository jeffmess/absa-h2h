require "absa-h2h/version"
require "yaml"

require 'absa-h2h/helpers'
require 'absa-h2h/transmission'

module Absa
  module H2h

    def self.build(options = {})
      header = Transmission::Header.new(options[:transmission_header])
      trailer = Transmission::Trailer.new(options[:transmission_trailer])
      
      raise "Error: Header and Trailer Status needs to be the same" if header.th_rec_status != trailer.tt_rec_status
      
      return { header: header, trailer: trailer }
    end
    
    def self.write_file!(header, trailer, destination)
      File.open(destination, 'w') do |f| 
        f.write(header)
        f.write(trailer) 
      end
    end
    
  end
end
