require "absa-h2h/version"
require "yaml"

module Absa
  module H2h
    
    def self.build(json)
      th = Transmission::Header.new(json[:transmission_header])
      return th
    end
    
    module Transmission
      LAYOUT_RULES = YAML.load(File.open("./lib/config/file_layout_rules.yml"))["transmission"]
      
      module InputValidation
        
        def self.included?
          layout_rules.each do |k,v|
            self.send :attr_accessor, k
          end
        end
        
        def layout_rules
          @layout_rules ||= LAYOUT_RULES[self.class.to_s.downcase.split("::")[-1]]
        end
        
        def validate!(options)
          options.each do |k,v|
            rule = layout_rules[k.to_s]

            raise "#{k}: Input too long" if v.length > rule['length']
            raise "#{k}: Invalid data" if rule['regex'] && ((v =~ /#{rule['regex']}/) != 0)
            raise "#{k}: Numeric value required" if (rule['a_n'] == 'N') && !(Float(v) rescue false)
          end
        end
        
      end
      
      class Header
        include InputValidation
        
        # attr_accessor :th_rec_id, :th_rec_status, :th_date, :th_client_code, :th_client_name
        #         attr_accessor :th_transmission_no, :th_destination, :th_for_use_of_ld_user
        #         
        def initialize(options = {})
          @string = " "*200
          validate! options
        end
        
        def to_s
          @string
        end
        
      end
      
      class Trailer
        include InputValidation
        
        # attr_accessor :tt_rec_id, :th_rec_status, :tt_no_of_recs
        #         
        def initialize(options = {})
          @string = " "*200
          validate! options
        end
        
        def to_s
          @string
        end
      end
    end
  end
end
