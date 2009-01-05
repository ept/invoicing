#--
# Copyright (c) 2009 Martin Kleppmann
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

#-------------------------------------------------------------------------------
# make sure our project's top level directory and the lib directory are added to
# the ruby search path.
#-------------------------------------------------------------------------------
$: << File.expand_path(File.join(File.dirname(__FILE__),"lib"))
$: << File.expand_path(File.dirname(__FILE__))


#-------------------------------------------------------------------------------
# load the global project configuration and add in the top level clean and
# clobber tasks so that other tasks can utilize those constants if necessary
# This loads up the defaults for the whole project configuration
#-------------------------------------------------------------------------------
require 'rubygems'
require 'tasks/config.rb'
require 'rake/clean'

#-------------------------------------------------------------------------------
# Main configuration for the project, these overwrite the items that are in
# tasks/config.rb
#-------------------------------------------------------------------------------
require 'invoicing'
Configuration.for("project") {
  name      "invoicing"
  version   Invoicing::VERSION
  author    "Martin Kleppmann"
  email     "martin@eptcomputing.com"
  homepage  "http://invoicing.rubyforge.org/"
}

#-------------------------------------------------------------------------------
# load up all the project tasks and setup the default task to be the
# test:default task.
#-------------------------------------------------------------------------------
Configuration.for("packaging").files.tasks.each do |tasklib|
  import tasklib
end
task :default => 'test:default'

#-------------------------------------------------------------------------------
# Finalize the loading of all pending imports and update the top level clobber
# task to depend on all possible sub-level tasks that have a name like
# ':clobber'  in other namespaces.  This allows us to say:
#
#   rake clobber
#
# and it will get everything.
#-------------------------------------------------------------------------------
Rake.application.load_imports
Rake.application.tasks.each do |t| 
  if t.name =~ /:clobber/ then
    task :clobber => [t.name] 
  end 
end

