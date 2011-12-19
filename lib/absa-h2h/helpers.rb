module InputValidation
  
  def validate!(options)
    options.each do |k,v|
      rule = @layout_rules[k.to_s]
      raise "#{k}: Argument is not a string" unless v.is_a? String
      raise "#{k}: Input too long" if v.length > rule['length']
      raise "#{k}: Invalid data" if rule['regex'] && ((v =~ /#{rule['regex']}/) != 0)
      raise "#{k}: Numeric value required" if (rule['a_n'] == 'N') && !(Float(v) rescue false)
    end
  end
  
end

module RecordWriter
  
  def layout_rules
    @layout_rules ||= YAML.load(File.open("./lib/config/#{self.class.to_s.split("::")[-2].underscore}.yml"))[self.class.to_s.split("::")[-1].underscore]
  end
  
  def set_layout_variables(options = {})
    @layout_rules = layout_rules
    
    options.each do |k,v|
      raise "#{k}: Argument is not a string" unless v.is_a? String
      self.class.send :attr_accessor, k
      self.send "#{k}=", v.upcase
    end
    
    @layout_rules.each do |k,v|
      self.class.send :attr_accessor, k
      self.send "#{k}=", v['value'] if v.has_key? "value"
    end
  end
          
  def to_s
    @string = " " * 200
    @string = "#{@string}"
    
    @layout_rules.each do |field_name,rule|
      value = self.send(field_name) || ""

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
