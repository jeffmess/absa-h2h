class String
  def underscore
    self.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def constantize
    names = self.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end
  
  def camelize
    self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  def blank?
    self !~ %r![^\s#{[0x3000].pack("U")}]!
  end
end

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
  
  def layout_rules
    @layout_rules ||= YAML.load(File.open("./lib/config/#{self.class.to_s.split("::")[-2].underscore}.yml"))[self.class.to_s.split("::")[-1].underscore]
  end
  
  def set_layout_variables(options = {})
    @layout_rules = layout_rules
    
    options.each do |k,v|
      self.instance_variable_set "@#{k}", v
    end
    
    @layout_rules.each do |k,v|
      self.instance_variable_set("@#{k}", v['value']) if v.has_key? "value"
    end
  end
          
  def to_s
    @string = " " * 200
    @string = "#{@string}"
    
    @layout_rules.each do |field_name,rule|
      value = self.instance_variable_get "@#{field_name}"
      value = "" if value.nil?

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
