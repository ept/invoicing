# Tools for dealing with names of controllers or models, passed to us by the user
# from the command line when invoking the generator. Designed to be included into
# a subclass of Rails::Generator::NamedBase.
#
# This code is inspired by the generator in restful_authentication.
module InvoicingGenerator
  module NameTools
  
    # Analyses a name provided by the user on the command line, and returns a hash
    # of useful bits of string based on that name:
    #   extract_name_details 'MegaBlurb/foo/BAR_BLOBS', :kind => :controller, :extension => '.rb'
    #   => {
    #        :underscore_base     => 'bar_blobs',           # last part of the name, underscored
    #        :camel_base          => 'BarBlobs',            # last part of the name, camelized
    #        :underscore_singular => 'bar_blob',            # underscore_base forced to singular form
    #        :camel_singular      => 'BarBlob',             # camel_base forced to singular form
    #        :underscore_plural   => 'bar_blobs',           # underscore_base forced to plural form
    #        :camel_plural        => 'BarBlobs',            # camel_base forced to plural form
    #        :class_path_array    => ['mega_blurb', 'foo'], # array of lowercase, underscored directory names
    #        :class_path          => 'mega_blurb/foo',      # class_path_array joined by filesystem separator
    #        :class_nesting_array => ['MegaBlurb', 'Foo'],  # array of camelized module names
    #        :class_nesting       => 'MegaBlurb::Foo',      # class_nesting_array joined by double colon
    #        :nesting_depth       => 2,                     # length of class_path array
    #
    #        # The following depend on the given :kind
    #        :file_path_base      => 'bar_blobs_controller.rb'                 # based on underscore_*
    #        :file_path_full      => 'app/controllers/mega_blurb/foo/bar_blobs_controller.rb', # full file path
    #        :class_name_base     => 'BarBlobsController',                     # file_path_base.camelize
    #        :class_name_full     => 'MegaBlurb::Foo::BarBlobsController',     # = class_nesting + class_name_base
    #      }
    #
    # Recognised options:
    #   :kind => :model -- use conventions for creating a model object from the name
    #   :kind => :controller -- use conventions for creating a controller from the name
    def extract_name_details(user_specified_name, options={})
      result = {}

      # See Rails::Generator::NamedBase#extract_modules
      modules = extract_modules(user_specified_name)
      base_name                 = modules.shift
      result[:class_path_array] = modules.shift
      file_path                 = modules.shift
      result[:class_nesting]    = modules.shift
      result[:nesting_depth]    = modules.shift
      result[:class_path]       = File.join(result[:class_path_array])
      result[:class_nesting_array] = result[:class_nesting].split('::')
      
      result[:underscore_base]     = base_name.underscore
      result[:camel_base]          = result[:underscore_base].camelize
      result[:underscore_singular] = result[:underscore_base].singularize
      result[:camel_singular]      = result[:underscore_singular].camelize
      result[:underscore_plural]   = result[:underscore_singular].pluralize
      result[:camel_plural]        = result[:underscore_plural].camelize
      
      if options[:kind] == :controller
        result[:file_path_base] = "#{result[:underscore_base]}_controller"
        path_prefix = File.join('app', 'controllers')
      elsif options[:kind] == :model
        result[:file_path_base] = result[:underscore_singular]
        path_prefix = File.join('app', 'models')
      else
        raise 'unknown kind of name'
      end
      
      result[:class_name_base] = result[:file_path_base].camelize
      result[:file_path_base] += (options[:extension] || ".rb")
      
      if result[:nesting_depth] == 0
        result[:file_path_full] = File.join(path_prefix, result[:file_path_base])
        result[:class_name_full] = result[:class_name_base]
      else
        result[:file_path_full] = File.join(path_prefix, result[:class_path], result[:file_path_base])
        result[:class_name_full] = "#{result[:class_nesting]}::#{result[:class_name_base]}"
      end
    
      #result[:routing_name] = result[:singular_name]
      #result[:routing_path] = result[:file_path].singularize
      #result[:controller_name] = result[:plural_name]

      result
    end
  end
end
