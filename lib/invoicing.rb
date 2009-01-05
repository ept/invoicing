#--
# Copyright (c) 2009 Martin Kleppmann
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Invoicing

  # The root directory of the project is considered to be the parent directory
  # of the 'lib' directory.
  #   
  # returns:: [String] The full expanded path of the parent directory of 'lib'
  #           going up the path from the current file.  Trailing
  #           File::SEPARATOR is guaranteed.
  #   
  def self.root_dir
    unless @root_dir
      path_parts = ::File.expand_path(__FILE__).split(::File::SEPARATOR)
      lib_index  = path_parts.rindex("lib")
      @root_dir = path_parts[0...lib_index].join(::File::SEPARATOR) + ::File::SEPARATOR
    end 
    return @root_dir
  end 

  # returns:: [String] The full expanded path of the +config+ directory
  #           below _root_dir_.  All parameters passed in are joined onto the
  #           result.  Trailing File::SEPARATOR is guaranteed if _args_ are
  #           *not* present.
  #   
  def self.config_path(*args)
    self.sub_path("config", *args)
  end 

  # returns:: [String] The full expanded path of the +data+ directory below
  #           _root_dir_.  All parameters passed in are joined onto the 
  #           result. Trailing File::SEPARATOR is guaranteed if 
  #           _*args_ are *not* present.
  #   
  def self.data_path(*args)
    self.sub_path("data", *args)
  end 

  # returns:: [String] The full expanded path of the +lib+ directory below
  #           _root_dir_.  All parameters passed in are joined onto the 
  #           result. Trailing File::SEPARATOR is guaranteed if 
  #           _*args_ are *not* present.
  #   
  def self.lib_path(*args)
    self.sub_path("lib", *args)
  end 

  def self.sub_path(sub,*args)
    sp = ::File.join(root_dir, sub) + File::SEPARATOR
    sp = ::File.join(sp, *args) if args
  end

end
require 'invoicing/version'

ActiveRecord::Base.send(:extend, Invoicing::ActiveRecordMethods)
ActiveRecord::Base.send(:extend, Invoicing::Tax::TaxCategory)
