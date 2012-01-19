module Absa
  module H2h
    module Transmission
      class Reply < Set
        
        class TransmissionStatus < Record; end
        class TransmissionRejectedReason < Record; end
        class EftStatus < Record; end
        class AcceptedReportReply < Record; end
        class RejectedMessage < Record; end
        
        def self.hash_from_s(string, transmission_type)
          set_info = {type: self.partial_class_name.underscore, data: []}

          string.split(/^/).each do |line|
            if Set.for_record(line, transmission_type) == self
              set_info[:data] << self.process_record(line[0, 198])
            end
          end

          set_info
        end
      
      end      
    end
  end
end