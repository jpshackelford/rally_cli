# Equivalent to a header guard in C/C++
# Used to prevent the class/module from being loaded more than once
unless defined? RallyCLI

verbosity, warn = $-v, $-w
$-v = $-w = nil

require 'fileutils'
require 'ostruct'
require 'pathname'
require 'stringio'
require 'tempfile'
require 'time'
require 'yaml'

require 'rubygems'
require 'cmdparse'
require 'highline/import'
require 'rally_rest_api'

$-v, $-w = verbosity, warn

# We only want to emit warnings in our own library.
module Kernel
  alias _warn warn
  def warn( message )
    _warn(message) if message =~ Regexp.new('rally_reports')
  end
end

module RallyCLI

  # :stopdoc:
  VERSION = '0.1.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, *args)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, *args)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    require_files = Dir.glob(search_me).sort
    
    # Attempt to require files again if first attempts fail due to missing
    # dependencies.
    retry_attempts = require_files.size
    errors = nil
    while( require_files.size > 0 && retry_attempts > 0)
      errors = []
      retry_attempts -= 1
      require_files.delete_if do |rb| 
        begin
          require rb
        rescue Exception => e
          errors << e
          false
        else
          true
        end
      end
    end
    if require_files.size > 0
      raise "Failed to load #{self.name}. Original errors were:\n\n" +
      errors.map{|e| e.to_s + "\n\t" + e.backtrace.join("\n\t")}.join("\n\n")
    end        
  end # def
  
end  # module RallyCLI

RallyCLI.require_all_libs_relative_to __FILE__

end  # unless defined?
