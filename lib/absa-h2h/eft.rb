module Absa
  module H2h
    module Transmission
      module Eft
        class Header< Record; end
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