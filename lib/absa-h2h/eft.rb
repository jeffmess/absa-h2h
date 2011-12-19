module Absa
  module H2h
    module Transmission
      class Eft < UserSet
        
        def validate!
          @transactions.each do |transaction|
            unless (@header.first_action_date..@header.last_action_date).cover?(transaction.action_date)
              raise "action_date: Must be within the range of first_action_date and last_action_date" 
            end
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

# (Time.now..Time.now+4).cover?(Time.now)