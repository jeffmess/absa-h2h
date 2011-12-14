require "absa-h2h/version"
require "yaml"

require 'absa-h2h/helpers'
require 'absa-h2h/transmission'
require 'absa-h2h/transmission/account_holder_verification'

module Absa
  module H2h

    def self.build(options = {})
      header = Transmission::Header.new(options[:transmission][:header])
      trailer = Transmission::Trailer.new(options[:transmission][:trailer])
      
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
