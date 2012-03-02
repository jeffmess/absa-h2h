module Absa
  module H2h
    module Transmission
    
      class Document < Set
        
        class Header < Record; end
        class Trailer < Record; end
        
        def self.from_s(string, transmission_type)
          options = self.hash_from_s(string, transmission_type)
          self.build(options[:data])
        end
        
        def to_file!(filename)
          File.open(destination, 'w') {|file| file.write(self.to_s) }
        end
        
        def from_file!(filename)
          self.from_s(File.open(filename, "rb").read)
        end
    
      end
    end    
  end
end
