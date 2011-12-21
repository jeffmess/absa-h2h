module Absa::H2h::Transmission
  class UserSet
    
    attr_accessor :header, :trailer, :transactions
    
    def self.build(content)      
      user_set = self.name.constantize.new
      
      transactions = content[:transactions].map do |transaction|
        class_name = "#{self.name}::#{transaction[:type].camelize}"
        class_name.constantize.new(transaction[:content])
      end
      
      user_set.header = "#{self.module_name}::Header".constantize.new(content[:header])
      user_set.trailer = "#{self.module_name}::Trailer".constantize.new(content[:trailer])
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
    
    def self.hash_from_s(string)
      user_set_info = {type: self.partial_class_name.underscore, content: {header: {}, trailer: {}, transactions: []}}
      
      records = string.split(/^/)
      
      records.each do |record|
        record = record[0, 198]
        
        self.record_types.each do |record_type|
          klass = "#{self.name}::#{record_type.camelize}".constantize
          
          if klass.matches_definition?(record)
            options = klass.string_to_hash(record)
            
            if record_type == 'header'
              user_set_info[:content][:header] = options
            elsif record_type == 'trailer'
              user_set_info[:content][:trailer] = options
            else
              user_set_info[:content][:transactions].push({type: record_type, content: options})
            end
          end              
        end            
      end
      
      user_set_info
    end
    
    def self.record_types
      self.layout_rules.map {|k,v| k}
    end
    
    def self.module_name
      self.name.split("::")[0..-1].join("::")
    end
    
    def self.partial_class_name
      self.name.split("::")[-1]
    end
    
    def self.layout_rules
      file_name = "./lib/config/#{self.partial_class_name.underscore}.yml"
      
      YAML.load(File.open(file_name))
    end
    
    
  end
end