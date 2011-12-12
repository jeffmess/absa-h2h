require "absa-h2h/version"
require "yaml"

module Absa
  module H2h
    
    def self.build(json)
      th = Transmission::Header.new(json[:transmission_header])
      return th
    end
    
    class Transmission
      class Header
        
        LAYOUT_RULES = YAML.load(File.open("./lib/config/file_layout_rules.yml"))["transmission"]["header"]
        
        attr_accessor :th_rec_id, :th_rec_status, :th_date, :th_client_code, :th_client_name
        attr_accessor :th_transmission_no, :th_destination, :th_for_use_of_ld_user
        
        def initialize(options = {})
          @string = " "*200
          validate! options
        end
        
        def validate!(options)
          options.each do |k,v|
            LAYOUT_RULES[k]
          end
        end
        
        def to_s
          
        end
        
      end
      
      class Trailer
        LAYOUT_RULES = YAML.load(File.open("./lib/config/file_layout_rules.yml"))["transmission"]["trailer"]
        
        attr_accessor :tt_rec_id, :th_rec_status, :tt_no_of_recs
        
        def initialize(options = {})
          @string = " "*200
          validate! options
        end
        
        def validate!(options)
          options.each do |k,v|
            LAYOUT_RULES[k]
          end
        end
        
        def to_s
          
        end
      end
    end
  end
end
