module Absa
  module H2h
    module Transmission
      class Eft < Set
        
        def validate_standard_transactions!
          if transactions.first.user_sequence_number != header.first_sequence_number
            raise "user_sequence_number: 1st Standard transactions user sequence number and the headers first sequence number must be equal." 
          end
          
          raise "user_sequence_number: Duplicate user sequence number. Transactions must have unique sequence numbers!" unless transactions.map(&:user_sequence_number).uniq.length == transactions.length

          unless transactions.map(&:user_sequence_number) == ((transactions.first.user_sequence_number.to_i)..(transactions.first.user_sequence_number.to_i + transactions.length-1)).map(&:to_s).to_a
            raise "user_sequence_number: Transactions must increment sequentially. Got: #{transactions.map(&:user_sequence_number)}" 
          end
          
          transactions.each do |transaction|
            first_action_date = Date.strptime(header.first_action_date, "%y%m%d")
            last_action_date = Date.strptime(header.last_action_date, "%y%m%d")
            action_date = Date.strptime(transaction.action_date, "%y%m%d")
            
            raise "action_date: Must be within the range of the headers first_action_date and last_action_date" unless (first_action_date..last_action_date).cover?(action_date)
            raise "rec_status: Transaction and Header record status must be equal" if header.rec_status != transaction.rec_status
          end
        end
        
        def validate_header_trailer!
          raise "rec_status: Trailer and Header record status must be equal" if header.rec_status != trailer.rec_status
          raise "bankserv_user_code: Trailer and Header user code must be equal." if header.bankserv_user_code != trailer.bankserv_user_code
          raise "first_sequence_number: Trailer and Header sequence number must be equal." if header.first_sequence_number != trailer.first_sequence_number
          raise "first_action_date: Trailer and Header first action date must be equal." if header.first_action_date != trailer.first_action_date
          raise "last_action_date: Trailer and Header last action date must be equal." if header.last_action_date != trailer.last_action_date
        end
        
        def validate_contra_records!
          transactions.select{|t| t.contra_record? }.each do |transaction|
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
            
            raise "user_code: Contra records user code must match the headers users code. Got #{transaction.user_code}. Expected #{header.bankserv_user_code}." unless transaction.user_code == header.bankserv_user_code
          end
        end
        
        def validate_trailer_transactions!
          unless trailer.last_sequence_number == transactions.last.user_sequence_number
            raise "last_sequence_number: Trailer records last sequence number must match the last contra records sequence number. Got #{trailer.last_sequence_number}. Expected #{transactions.last.user_sequence_number}"
          end
          
          debit_records = transactions.select {|t| t.bankserv_record_identifier.to_i == 50 }
          credit_records = transactions.select {|t| t.bankserv_record_identifier.to_i == 10 }
          
          unless trailer.no_debit_records.to_i == self.debit_records.count + self.credit_contra_records.count
            raise "no_debit_records: Trailer records number of debit records must match the number of debit records. Expected #{debit_records.count}. Got #{trailer.no_debit_records}."
          end
          
          unless trailer.no_credit_records.to_i == self.credit_records.count + self.debit_contra_records.count
            raise "no_credit_records: Trailer records number of credit records must match the number of credit records and contra debit records. Expected #{self.credit_records.count + self.debit_contra_records.count}. Got #{trailer.no_credit_records}."
          end
          
          unless trailer.no_contra_records.to_i == self.contra_records.count
            raise "no_contra_records: Trailer records number of contra records must match the number of contra records. Expected #{self.contra_records.count}. Got #{trailer.no_contra_records}."
          end
          
          unless trailer.total_debit_value.to_i == self.total_debit_transactions
            raise "total_debit_value: Trailer records total debit value must equal the sum amount of all transactions and credit contra records. Expected #{self.total_debit_transactions}. Got #{trailer.total_debit_value.to_i}."
          end
          
          unless trailer.total_credit_value.to_i == self.total_credit_transactions
            raise "total_credit_value: Trailer records total credit value must equal the sum amount of all transactions and debit contra records. Expected #{self.total_credit_transactions}. Got #{trailer.total_credit_value.to_i}."
          end
          
          unless trailer.hash_total_of_homing_account_numbers.to_i == self.homing_numbers_hash_total
            raise "hash_total_of_homing_account_numbers: Trailers hash total of homing account numbers does not match. Expected #{self.homing_numbers_hash_total}. Got #{trailer.hash_total_of_homing_account_numbers}."
          end
        end
        
        def validate!
          validate_standard_transactions!
          validate_header_trailer!
          validate_contra_records!
          validate_trailer_transactions!          
        end
        
        def contra_records
          transactions.select {|t| t.contra_record? }
        end
        
        def standard_records
          transactions.select {|t| !t.contra_record? }
        end
        
        def debit_records
          # Standard records only
          transactions.select {|t| t.bankserv_record_identifier.to_i == 50 }
        end
        
        def credit_records
          # Standard records only
          transactions.select {|t| t.bankserv_record_identifier.to_i == 10 }
        end
        
        def debit_contra_records
          transactions.select {|t| t.contra_record? && t.bankserv_record_identifier.to_i == 52}
        end
        
        def credit_contra_records
          transactions.select {|t| t.contra_record? && t.bankserv_record_identifier.to_i == 12}
        end
        
        def total_debit_transactions
          # including credit contra records
          ccr = self.credit_contra_records == [] ? 0 : self.credit_contra_records.map(&:amount).map(&:to_i).inject(&:+)
          self.standard_records.map(&:amount).map(&:to_i).inject(&:+) + ccr
        end
        
        def total_credit_transactions
          # including debit contra records
          dcr = self.debit_contra_records == [] ? 0 : self.debit_contra_records.map(&:amount).map(&:to_i).inject(&:+)
          (self.credit_records.map(&:amount).map(&:to_i).inject(&:+) || 0) + dcr
        end
        
        def calculate_contra_record_total(contra_record)
          transactions_for_contra_record(contra_record).map(&:amount).map(&:to_i).inject(&:+)
        end
        
        def transactions_for_contra_record(contra_record)
          contra_records = self.contra_records.map(&:user_sequence_number)
          sequence = transactions.map(&:user_sequence_number)
          
          if contra_records.index(contra_record.user_sequence_number) == 0 # First contra record in user set
            previous_contra_record = contra_record.user_sequence_number
            start_point = 0
          else
            previous_contra_record = contra_records[contra_records.index(contra_record.user_sequence_number)-1]
            start_point = sequence.index(previous_contra_record) + 1
          end
          
          end_point = sequence.index(contra_record.user_sequence_number)-1
          transactions[start_point..end_point]
        end
        
        def homing_numbers_hash_total
          ns_homing_account_number_total = self.standard_records.map(&:non_standard_homing_account_number).empty? ? 0 : self.standard_records.map(&:non_standard_homing_account_number).map(&:to_i).inject(&:+)
          field9 = transactions.map(&:homing_account_number).map(&:to_i).inject(&:+) + ns_homing_account_number_total
        end
        
        class Header < Record; end
        class ContraRecord < Record
        
          def contra_record?
            true
          end
          
          def validate!(options={})
            super(options)
            raise "homing_branch: Should match the user branch. Got #{@homing_branch}. Expected #{@user_branch}." unless @homing_branch == @user_branch
            raise "homing_account_number: Should match the user nominated account number. Got #{@homing_account_number}. Expected #{@user_nominated_account}." unless @homing_account_number == @user_nominated_account
            raise "user_ref: Position 1 - 10 is compulsory. Please provide users abbreviated name." if @user_ref[0..9].blank?
            raise "user_ref: Position 11 - 16 is compulsory and must be set to 'CONTRA'. Got #{@user_ref[10..15]}" if @user_ref[10..15] != "CONTRA"
          end
          
        end

        class StandardRecord < Record
          
          def contra_record?
            false
          end
          
          def validate!(options={})
            super(options)
            
            raise "user_ref: Position 1 - 10 is compulsory. Please provide users abbreviated name." if @user_ref[0..11].blank?
            raise "homing_account_name: Not to be left blank." if @homing_account_name.blank?
          end
          
        end

        class Trailer < Record; end
      end
    end
  end
end
