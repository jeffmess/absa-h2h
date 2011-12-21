module Absa
  module H2h
    module Transmission
    
      class Document
        
        class Header < Record; end
        class Trailer < Record; end
        
        attr_accessor :header, :trailer, :user_sets
      
        def initialize(options = {})
          @header = nil
          @user_sets = []
          @trailer = nil
        end

        def self.build(options = {})
          document = self.new
          document.build_header options[:transmission][:header]
          document.build_trailer options[:transmission][:trailer]
        
          options[:transmission][:user_sets].each do |user_set|
            document.build_user_set(user_set)
          end
        
          document.validate!
          document
        end
      
        def validate!
          #raise "Error: Header and Trailer Status needs to be the same" if @header.th_rec_status != @trailer.tt_rec_status
        end
      
        def build_header(options = {})
          @header = Header.new(options)
        end
      
        def build_trailer(options = {})
          @trailer = Trailer.new(options)
        end
      
        def build_user_set(options = {})
          class_name = "Absa::H2h::Transmission::#{options[:type].camelize}"
          @user_sets.push class_name.constantize.build(options[:content])
        end
      
        def to_s
          lines = []
          lines << @header.to_s
        
          @user_sets.each {|set| lines << set.to_s}
        
          lines << @trailer.to_s
          lines.join
        end
        
        def self.hash_from_s(string)
          document_info = {transmission: {header: {}, trailer: {}, user_sets: []}}
          lines = string.split(/^/)
          
          # pull first and last line off and handle separately to user sets
          
          document_info[:transmission][:header] = Header.string_to_hash(lines.shift)
          document_info[:transmission][:trailer] = Trailer.string_to_hash(lines.pop)
          
          # look for rec_ids, split into chunks, and pass each related class a piece of string
          
          buffer = []
          current_user_set = nil
          
          lines.each do |line|
            record_id = line[0..2]
            user_set = UserSet.for_record_id(record_id)
            
            if current_user_set and user_set != current_user_set and buffer.length > 0
              document_info[:transmission][:user_sets] << user_set.hash_from_s(buffer.join)
              buffer = []
            else  
              buffer << line
            end
            
            current_user_set = user_set
          end
          
          if buffer.length > 0
            document_info[:transmission][:user_sets] << current_user_set.hash_from_s(buffer.join)
          end
          
          document_info
        end
        
        def self.from_s(string)
          options = self.hash_from_s(string)
          Document.build(options)
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
