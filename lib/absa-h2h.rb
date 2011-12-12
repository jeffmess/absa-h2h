require "absa-h2h/version"
require "yaml"

module Absa
  module H2h
    
    def self.build(json)
      th = Transmission::Header.new(json[:transmission_header])
    end
    
    module Transmission
      LAYOUT_RULES = YAML.load(File.open("./lib/config/file_layout_rules.yml"))["transmission"]
      
      module InputValidation
        
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
      
      module RecordWriter
        
        def set_layout_variables(options = {})
          options.each do |k,v|
            self.instance_variable_set "@#{k}", v
            @layout_rules[k.to_s]["value"] = v
          end
        end
                
        def to_s
          @layout_rules.each do |field_name,rule|
            # puts self.inspect
            value = rule["value"]

            if rule['a_n'] == 'N'
              value = value.rjust(rule['length'], "0")
            elsif rule['a_n'] == 'A'
              value = value.ljust(rule['length'], " ")
            end
            
            puts value
            offset = rule['offset'] - 1
            length = rule['length']
            
            # @string[offset..length] = value
            
          end 
          puts @string
          @string
          
        end
        
      end
      
      class Header
        include InputValidation
        include RecordWriter
        
        # attr_accessor :th_rec_id, :th_rec_status, :th_date, :th_client_code, :th_client_name, :th_transmission_no, :th_destination, :th_for_use_of_ld_user
        
        def initialize(options = {})
          validate! options
          set_layout_variables(options)
          to_s
        end
        
      end
      
      class Trailer
        include InputValidation
        include RecordWriter
        
        def initialize(options = {})
          validate! options
          
        end

      end
    end
  end
end
