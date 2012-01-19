module RecordWriter
  
  def layout_rules
    @layout_rules ||= self.class.class_layout_rules  
  end
  
  def exposed_rules
    layout_rules.select {|key, rule| !(rule["expose"] == false && rule.has_key?("expose")) }
  end
  
  def filler_rules
    @filler_rules ||= self.class.filler_layout_rules  
  end
  
  def set_layout_variables(options = {})
    self.class.define_attribute_accessors
    
    options.each do |k,v|
      raise "#{k}: Argument is not a string" unless v.is_a? String
      self.class.send :attr_accessor, k
      self.send "#{k}=", v.upcase
    end
    
    layout_rules.each do |k,v|
      self.class.send(:attr_accessor, k) unless (v["expose"] && v["expose"] == false)
      # self.send "#{k}=", v['fixed_val'] if v.has_key? ""
    end
  end
  
  def set_filler(string)
    filler_rules.each do |key, value|
      string[(value["offset"] - 1), value["length"]] = value["fixed_val"]
    end
    
    return string
  end
          
  def to_s
    @string = " " * 198 + "\r\n"
    @string = set_filler(@string)
    
    @string = "#{@string}"
    
    self.exposed_rules.each do |field_name,rule|
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
      
      raise "#{k}: Invalid character used in #{v}" unless (k == :user_ref) || (v =~ /^[A-Z0-9\.\/\-\&\*\,\(\)\<\+\$\;\>\=\'\ ]*$/) # host to host layout annexure 3
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
    
    def filler_layout_rules
      class_layout_rules.select {|key, rule| rule.has_key?("expose") && rule["expose"] == false && rule.has_key?("fixed_val")}
    end
      
    def define_attribute_accessors
      self.class_layout_rules.each do |k,v|
        (class << self; self; end).send :attr_accessor, k
        self.send :attr_accessor, k
      end

    end
    
  end
  
end
