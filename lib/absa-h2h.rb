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
        
        # def self.included?
        #   layout_rules.each do |k,v|
        #     self.send :attr_accessor, k
        #   end
        # end
        
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
        
        def self.included?
          @string = " "*200
        end
        
        def to_s
          layout_rules.each do |field_name,rule|
            puts field_name
            puts rule.inspect
            value = self.send field_name
            

            
            # pad values
            
            if rule['a_n'] == 'N'
              value = value.rjust(rule['length'], "0")
            elsif rule['a_n'] == 'A'
              value = value.ljust(rule['length'], " ")
            end
            
            # insert into string
            offset = rule['offset'] - 1
            length = rule['length']
            
            @string[offset..length] = value
          end
          
          @string
        end
        
      end
      
      class Header
        include InputValidation
        include RecordWriter
        
        attr_accessor :th_rec_id, :th_rec_status, :th_date, :th_client_code, :th_client_name, :th_transmission_no, :th_destination, :th_for_use_of_ld_user
        
        def initialize(options = {})
          validate! options

          puts self.methods.inspect
          self.th_rec_id='test'
          
          options.each do |k,v|
            instance_variable_set "@#{k}", v
          end
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
