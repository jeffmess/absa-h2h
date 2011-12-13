module InputValidation
  
  def validate!(options)
    options.each do |k,v|
      rule = @layout_rules[k.to_s]
      raise "#{k}: Input too long" if v.length > rule['length']
      raise "#{k}: Invalid data" if rule['regex'] && ((v =~ /#{rule['regex']}/) != 0)
      raise "#{k}: Numeric value required" if (rule['a_n'] == 'N') && !(Float(v) rescue false)
    end
  end
  
end

module RecordWriter
  
  def set_layout_variables(options = {})
    rules = YAML.load(File.open("./lib/config/#{self.class.to_s.downcase.split("::")[-2]}.yml"))
    
    @layout_rules ||= rules[self.class.to_s.downcase.split("::")[-1]]
    options.each do |k,v|
      self.instance_variable_set "@#{k}", v
    end
  end
          
  def to_s
    @string = " " * 200
    @string = "#{@string}"
    
    @layout_rules.each do |field_name,rule|
      value = self.instance_variable_get "@#{field_name}"

      if rule['a_n'] == 'N'
        value = value.rjust(rule['length'], "0")
      elsif rule['a_n'] == 'A'
        value = value.ljust(rule['length'], " ")
      end
      
      offset = rule['offset'] - 1
      length = rule['length']
      
      @string[(offset), length] = value
    end 
    
    @string
  end
end