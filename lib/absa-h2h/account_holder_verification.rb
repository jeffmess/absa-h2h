module Absa
  module H2h
    module Transmission
      class AccountHolderVerification < UserSet
        
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end
        
        def validate! 
          unless @trailer.no_det_recs == @transactions.length.to_s
            raise "no_det_recs mismatch: expected #{@trailer.no_det_recs}, got #{@transactions.length}" 
          end

          unless @transactions.map {|t| t.seq_no} == (1..(@transactions.length)).map(&:to_s).to_a
            raise "seq_no mismatch: #{@transactions.map {|t| t.seq_no}}"
          end
             
        end
        
        def self.hash_from_s(string)
          user_set_info = {type: self.name.split("::")[-1].underscore, content: {header: {}, trailer: {}, transactions: []}}
          
          records = string.split(/^/)
          
          records.each do |record|
            record = record[0..197]
            ['Header','Trailer','InternalAccountDetail','ExternalAccountDetail'].each do |record_type|
              klass = "Absa::H2h::Transmission::AccountHolderVerification::#{record_type}".constantize
              
              if klass.matches_definition?(record)
                options = klass.string_to_hash(record)
                
                if record_type == 'Header'
                  user_set_info[:content][:header] = options
                elsif record_type == 'Trailer'
                  user_set_info[:content][:trailer] = options
                else
                  user_set_info[:content][:transactions].push({type: record_type.underscore, content: options})
                end
              end              
            end            
          end
          
          user_set_info
        end

      end      
    end
  end
end