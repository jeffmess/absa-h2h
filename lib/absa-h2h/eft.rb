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

          unless @transactions.map(&:user_sequence_number) == ((@transactions.first.user_sequence_number.to_i)..(@transactions.first.user_sequence_number.to_i + @transactions.length-1)).map(&:to_s).to_a
            raise "user_sequence_number: Transactions must increment sequentially. Got: #{@transactions.map(&:user_sequence_number)}" 
          end
          
          raise "rec_status: Trailer and Header record status must be equal" if @header.rec_status != @trailer.rec_status
          raise "bankserv_user_code: Trailer and Header user code must be equal." if @header.bankserv_user_code != @trailer.bankserv_user_code
          raise "first_sequence_number: Trailer and Header sequence number must be equal." if @header.first_sequence_number != @trailer.first_sequence_number
          raise "first_action_date: Trailer and Header first action date must be equal." if @header.first_action_date != @trailer.first_action_date
          raise "last_action_date: Trailer and Header last action date must be equal." if @header.last_action_date != @trailer.last_action_date
          
          @transactions.each do |transaction|
            first_action_date = Date.strptime(@header.first_action_date, "%y%m%d")
            last_action_date = Date.strptime(@header.last_action_date, "%y%m%d")
            action_date = Date.strptime(transaction.action_date, "%y%m%d")
            
            raise "action_date: Must be within the range of the headers first_action_date and last_action_date" unless (first_action_date..last_action_date).cover?(action_date)
            raise "rec_status: Transaction and Header record status must be equal" if @header.rec_status != transaction.rec_status
          end
          
          @transactions.select{|t| t.contra_record? }.each do |transaction|
            # Loop used to validate contra records against the standard records
            unless calculate_contra_record_total(transaction) == transaction.amount.to_i
              raise "amount: Contra record amount must be the sum amount of all preceeding transactions. Expected #{calculate_contra_record_total(transaction)}. Got #{transaction.amount}." 
            end
            
            transactions = transactions_for_contra_record(transaction)
            
            if transactions.map(&:action_date).uniq.length > 1
              raise "action_date: Contra records action date must be equal to all preceeding standard transactions action date. Got #{transactions_for_contra_record(transaction).map(&:action_date)}." 
            end
            
            if (transactions.map(&:user_nominated_account).uniq.length > 1) or (transactions.map(&:user_nominated_account).first != transaction.user_nominated_account)
              raise "user_nominated_account: Contra records user nominated account must match all preceeding standard transactions user nominated accounts. Got #{transactions.map(&:user_nominated_account)}."
            end
            
            if (transactions.map(&:user_branch).uniq.length > 1) or (transactions.map(&:user_branch).first != transaction.user_branch)
              raise "user_branch_code: Contra records user branch must match all preceeding standard transactions user branch. Got #{transactions.map(&:user_branch)}."
            end
          end
          
        end
        
        def calculate_contra_record_total(contra_record)
          transactions_for_contra_record(contra_record).map(&:amount).map(&:to_i).inject(&:+)
        end
        
        def transactions_for_contra_record(contra_record)
          contra_records = @transactions.select {|t| t.contra_record? }.map(&:user_sequence_number)
          sequence = @transactions.map(&:user_sequence_number)
          
          if contra_records.index(contra_record.user_sequence_number) == 0 # First contra record in user set
            previous_contra_record = contra_record.user_sequence_number
            start_point = 0
          else
            previous_contra_record = contra_records[contra_records.index(contra_record.user_sequence_number)-1]
            start_point = sequence.index(previous_contra_record) + 1
          end
          
          end_point = sequence.index(contra_record.user_sequence_number)-1
          @transactions[start_point..end_point]
        end
        
        class Header < Record; end
        class ContraRecord < Record
        
          def contra_record?
            true
          end
          
          def validate!(options={})
            super(options)
            raise "homing_branch: Should match the user branch. Got #{@homing_branch}. Expected #{@user_branch}." unless @homing_branch == @user_branch
            # raise "user_reference: Position 1 - 10 is compulsory. Please provide users abbreviated name." if @user_reference[0..11].blank?
            # raise "homing_account_name: Not to be left blank." if @homing_account_name.blank?
          end
          
        end

        class StandardRecord < Record
          
          def contra_record?
            false
          end
          
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
