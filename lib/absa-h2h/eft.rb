module Absa
  module H2h
    module Transmission
      class Eft < UserSet
        
        def validate!
          # TODO. Only first standard transaction usn should == the headers first sequence number.
          # Not just the first transaction.
          if @transactions.first.user_sequence_number != @header.first_sequence_number
            raise "user_sequence_number: 1st Standard transactions user sequence number and the headers first sequence number must be equal." 
          end
          
          raise "user_sequence_number: Duplicate user sequence number. Transactions must have unique sequence numbers!" unless @transactions.map(&:user_sequence_number).uniq.length == @transactions.length
          raise "user_sequence_number: Transactions must increment sequentially." unless @transactions.map(&:user_sequence_number).sort.last.to_i - @transactions.map(&:user_sequence_number).sort.first.to_i == @transactions.length-1
          
          raise "rec_status: Footer and Header record status must be equal" if @header.rec_status != @trailer.rec_status
          
          @transactions.each do |transaction|
            first_action_date = Date.strptime(@header.first_action_date, "%y%m%d")
            last_action_date = Date.strptime(@header.last_action_date, "%y%m%d")
            action_date = Date.strptime(transaction.action_date, "%y%m%d")
            
            raise "action_date: Must be within the range of the headers first_action_date and last_action_date" unless (first_action_date..last_action_date).cover?(action_date)
            raise "rec_status: Transaction and Header record status must be equal" if @header.rec_status != transaction.rec_status
          end
        end
        
        class Header < Record; end
        class ContraRecord < Record; end

        class StandardRecord < Record
          
          def validate!(options={})
            super(options)
            raise "user_reference: Position 1 - 10 is compulsory. Please provide users abbreviated name." if @user_reference[0..11].blank?
            raise "homing_account_name: Not to be left blank." if @homing_account_name.blank?
          end
          
        end

        class Trailer < Record; end
      end
    end
  end
end
