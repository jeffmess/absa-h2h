module Absa
  module H2h
    module Eft
      class RejectionCode
        
        def self.reasons
          self.config['reasons']
        end
      
        def self.qualifiers
          self.config['qualifiers']
        end
        
        def self.reason_for_code(code)
          self.reasons[code]
        end
        
        def self.qualifier_for_code(code)
          self.qualifiers[code]
        end
      
        def self.config
          file_name = "#{Absa::H2h::CONFIG_DIR}/eft_rejection_codes.yml"
          YAML.load(File.open(file_name))
        end
        
      end
    end
  end
end