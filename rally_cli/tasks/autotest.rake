# Attempt to load supporting libraries.
%w(autotest escape).each do |lib|
  begin
    require lib
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", true}
  rescue LoadError
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", false}
  end
end

# Windows Platform?
WIN32 = %r/djgpp|(cyg|ms|bcc)win|mingw/ =~ RUBY_PLATFORM unless defined? WIN32

if HAVE_AUTOTEST
  
  desc 'Continuously test with ZenTest'
  task :autotest do
    
    ENV['RSPEC'] = 'true'
    
    style = Autotest.autodiscover
    style.inspect
    target = Autotest
    unless style.empty? then
      mod = "autotest/#{style.join("_")}"
      puts "loading #{mod}"
      begin
        require mod
      rescue LoadError
        abort "Autotest style #{mod} doesn't seem to exist. Aborting."
      end
      target = Autotest.const_get(style.map {|s| s.capitalize}.join)
    end
    target.run    
  end
  
end #if HAVE_AUTOTEST
