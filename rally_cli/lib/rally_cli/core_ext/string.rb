class String
  
  def underscore        
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    tr(" ", "_").
    downcase.gsub(/_id$/,'_i_d')        
  end
  
  def camel_case
    self.tr(" ", "_").split(/\./).
    map{ |word| word.split(/_/).
      map{ |word| word.capitalize }.join}.join('.')
  end
  
  def dasherize
    self.tr('_', '-')
  end

end
