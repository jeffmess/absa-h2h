module Absa
  module H2h
    module Transmission
    
      class Document
      
        def initialize(options = {})
          @header = nil
          @user_sets = []
          @trailer = nil
        end

        def self.build(options = {})
          file = self.new
          file.build_header options[:transmission][:header]
          file.build_trailer options[:transmission][:trailer]
        
          options[:transmission][:user_sets].each do |user_set|
            file.build_user_set(user_set)
          end
        
          #file.validate!
        
          file
        end
      
        def validate!
          raise "Error: Header and Trailer Status needs to be the same" if @header.th_rec_status != @trailer.tt_rec_status
        end
      
        def build_header(options = {})
          @header = Transmission::Header.new(options)
        end
      
        def build_trailer(options = {})
          @trailer = Transmission::Trailer.new(options)
        end
      
        def build_user_set(options = {})
          class_name = "Absa::H2h::Transmission::#{options[:type].camelize}"
          @user_sets.push class_name.constantize.build(options[:content])
        end
    
        def self.write_file!(header, trailer, destination)
          File.open(destination, 'w') do |f| 
            f.write(header)
            f.write(trailer) 
          end
        end
      
        def to_s
          lines = []
          lines << @header.to_s
        
          @user_sets.each do |set|
            lines << set.to_s
          end
        
          lines << @trailer.to_s
          lines.join("\r\n")
        end
    
      end
    end    
  end
end
