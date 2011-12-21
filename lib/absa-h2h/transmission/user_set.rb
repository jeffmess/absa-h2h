module Absa::H2h::Transmission
  class UserSet
    
    attr_accessor :header, :trailer, :transactions
    
    def self.build(content)
      module_name = self.name.split("::")[0..-1].join("::")
      
      user_set = self.name.constantize.new
      
      transactions = content[:transactions].map do |transaction|
        class_name = "#{self.name}::#{transaction[:type].camelize}"
        class_name.constantize.new(transaction[:content])
      end
      
      user_set.header = "#{module_name}::Header".constantize.new(content[:header])
      user_set.trailer = "#{module_name}::Trailer".constantize.new(content[:trailer])
      user_set.transactions = transactions
                
      user_set.validate!
      user_set
    end
    
    def validate!
      
    end
    
    def to_s
      lines = []
      lines << @header.to_s
                
      @transactions.each do |transaction|
        lines << transaction.to_s
      end
                
      lines << @trailer.to_s
      lines.join
    end
    
    def self.for_record_id(record_id)
      case record_id
      when '000','999'
        'something'
        #return Absa::H2h::Transmission::AccountHolderVerification
      when '030','031','039'
        return Absa::H2h::Transmission::AccountHolderVerification
      end
      
    end
    
  end
end