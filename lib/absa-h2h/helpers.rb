module RecordWriter
  
  def layout_rules
    @layout_rules ||= self.class.class_layout_rules  
  end
  
  def set_layout_variables(options = {})
    self.class.define_attribute_accessors
    
    options.each do |k,v|
      raise "#{k}: Argument is not a string" unless v.is_a? String
      self.class.send :attr_accessor, k
      self.send "#{k}=", v.upcase
    end
    
    layout_rules.each do |k,v|
      self.class.send :attr_accessor, k
      self.send "#{k}=", v['value'] if v.has_key? "value"
    end
  end
          
  def to_s
    @string = " " * 198 + "\r\n"
    @string = "#{@string}"
    
    self.layout_rules.each do |field_name,rule|
      value = self.send(field_name) || ""

      value = value.rjust(rule['length'], "0") if rule['a_n'] == 'N'
      value = value.ljust(rule['length'], " ") if rule['a_n'] == 'A'
      
      offset = rule['offset'] - 1
      length = rule['length']
      
      @string[(offset), length] = value
    end 
    
    @string
  end
  
  def validate!(options)
    options.each do |k,v|
      rule = layout_rules[k.to_s]

      raise "#{k}: Argument is not a string" unless v.is_a? String
      raise "#{k}: Input too long" if v.length > rule['length']
      raise "#{k}: Invalid data" if rule['regex'] && ((v =~ /#{rule['regex']}/) != 0)
      raise "#{k}: Invalid data - expected #{rule['fixed_val']}, got #{v}" if rule['fixed_val'] && (v != rule['fixed_val'])
      raise "#{k}: Numeric value required" if (rule['a_n'] == 'N') && !(Float(v) rescue false)
    end
  end
  
  module ClassMethods
    
    def class_layout_rules
      file_name = "#{Absa::H2h::CONFIG_DIR}/#{self.name.split("::")[-2].underscore}.yml"
      record_type = self.name.split("::")[-1].underscore
      
      YAML.load(File.open(file_name))[record_type]
    end
      
    def define_attribute_accessors
      self.class_layout_rules.each do |k,v|
        (class << self; self; end).send :attr_accessor, k
        self.send :attr_accessor, k
      end

    end
    
  end
  
end
