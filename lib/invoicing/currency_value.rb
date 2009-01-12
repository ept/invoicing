module Invoicing
  # = Input and output of monetary values
  #
  # This module simplifies model objects which need to store monetary values. It automatically takes care
  # of currency rounding conventions and formatting values for output.
  #
  # == General notes on currency precision and rounding
  #
  # It is important to deal carefully with rounding errors in accounts. If the figures don't add up exactly,
  # you may have to pay for expensive accountant hours while they try to find out where the missing pennies or
  # cents have gone -- better to avoid this trouble from the start. Because of this, it is strongly recommended
  # that you use fixed-point or decimal datatypes to store any sort of currency amounts, never floating-point
  # numbers.
  #
  # Keep in mind that not all currencies subdivide their main unit into 100 smaller units; storing four digits
  # after the decimal point should be enough to allow you to expand into other currencies in future. Also leave
  # enough headroom in case you ever need to use an inflated currency. For example,
  # if you are using MySQL, <tt>decimal(20,4)</tt> may be a good choice for all your columns which store
  # monetary amounts. The extra few bytes aren't going to cost you anything.
  #
  # On the other hand, it doesn't usually make sense to store monetary values with a higher precision than is
  # conventional for a particular currency (usually this is related to the value of the smallest coin in
  # circulation, but conventions may differ). For example, if your currency rounds to two decimal places, then
  # you should also round every monetary amount to two decimal places before storing it. If you store values
  # at a higher precision than you display, your numbers may appear to not add up correctly when you present
  # them to users. Fortunately, this module automatically performs currency-specific rounding for you.
  #
  # == Using +attr_currency_value+
  #
  # This module simplifies model objects which need to store monetary values, by automatically taking care
  # of currency rounding conventions.
  module CurrencyValue
    
    # Data about currencies, indexed by ISO 4217 code. (Currently a very short list, in need of extending.)
    # The values are hashes, in which the following keys are recognised: 
    # <tt>:round</tt>::  Smallest unit of the currency in normal use, to which values are rounded. Default is 0.01.
    # <tt>:symbol</tt>:: Symbol or string usually used to denote the currency. Encoded as UTF-8. Default is ISO 4217 code.
    # <tt>:suffix</tt>:: +true+ if the currency symbol appears after the number, +false+ if it appears before. Default +false+.
    CURRENCIES = {
      'EUR' => {:symbol => "\xE2\x82\xAC"},                   # Euro
      'GBP' => {:symbol => "\xC2\xA3"},                       # Pound Sterling
      'USD' => {:symbol => "$"},                              # United States Dollar
      'CAD' => {:symbol => "$"},                              # Canadian Dollar
      'AUD' => {:symbol => "$"},                              # Australian Dollar
      'CNY' => {:symbol => "\xE5\x85\x83", :suffix => true},  # Chinese Yuan (RMB)
      'INR' => {:symbol => "\xE2\x82\xA8"},                   # Indian Rupee
      'JPY' => {:symbol => "\xC2\xA5",     :round  => 1}      # Japanese Yen
    }
    
    module ActMethods
      def attr_currency_value(*attrs)
        previous_info = (respond_to? :currency_value_class_info) ? currency_value_class_info : nil
        if previous_info.nil?
          include ::Invoicing::CurrencyValue
          before_validation :convert_currency_values
        end
        
        @currency_value_class_info = ::Invoicing::CurrencyValueClassInfo.new(self, previous_info, attrs, attrs.extract_options!)
      end
    end # module ActMethods
    
    
    def self.included(base)
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      def currency_value_class_info #:nodoc:
        @currency_value_class_info || superclass.currency_value_class_info
      end
    end
    
    # Called automatically via +before_validation+. Performs the conversion of any values assigned
    # to +CurrencyValue+ attributes.
    def convert_currency_values
      info = self.class.currency_value_class_info
      currency_info = info.currency_info_for(self)
      return if currency_info.nil?
      
    end
    
  end

  class CurrencyValueClassInfo #:nodoc:
    attr_reader :model_class, :previous_info, :attrs, :options
    
    def initialize(model_class, previous_info, attrs, options)
      @model_class = model_class
      @previous_info = previous_info # The CurrencyValueClassInfo object if created previously on the same class
      @attrs = attrs
      new_attrs.each{|attr| generate_attrs(attr)}

      @options = previous_info.nil? ? {:currency => 'currency', :currency_code => nil} : previous_info.options.clone
      @options.update(options)
    end
    
    # Returns a list of all attributes which have not already been dealt with by a previous instance
    # of CurrencyValueClassInfo on the same class.
    def new_attrs
      if @previous_info then
        attrs - @previous_info.attrs
      else
        attrs
      end
    end
    
    # Generates the getter and setter method for attribute +attr+.
    def generate_attrs(attr)
      model_class.class_eval do
        define_method(attr) do
          convert_currency_values
          read_attribute(attr)
        end
        
        define_method("#{attr}=") do |new_value|
          write_attribute(attr, new_value)
        end
        
        define_method("#{attr}_formatted") do
          self.class.currency_value_class_info.format_value(self, send(attr))
        end
      end
    end
    
    # Returns the value of the currency code column of +object+, if available; otherwise the
    # default currency code (set by the <tt>:currency_code</tt> option), if available; +nil+ if all
    # else fails.
    def currency_of(object)
      if object.attributes.has_key?(options[:currency])
        object.send(options[:currency])
      else
        options[:currency_code]
      end
    end
    
    # Returns a hash of information about the currency used by model +object+. Contains the following keys:
    # <tt>:code</tt>::   The ISO 4217 code of the currency.
    # <tt>:round</tt>::  Smallest unit of the currency in normal use, to which values are rounded. Default is 0.01.
    # <tt>:symbol</tt>:: Symbol or string usually used to denote the currency. Encoded as UTF-8. Default is ISO 4217 code.
    # <tt>:suffix</tt>:: +true+ if the currency symbol appears after the number, +false+ if it appears before.
    # <tt>:space</tt>::  Whether or not to leave a space between the number and the currency symbol.
    # <tt>:digits</tt>:: Number of digits to display after the decimal point.
    def currency_info_for(object)
      valid_options = [:symbol, :round, :suffix, :space, :digits, :format]
      code = currency_of(object)
      info = {:code => code, :symbol => code, :round => 0.01, :suffix => nil, :space => nil, :digits => nil}
      options.each_pair {|key, value| info[key] = value if valid_options.include? key }
      if ::Invoicing::CurrencyValue::CURRENCIES.has_key? code
        info.update(::Invoicing::CurrencyValue::CURRENCIES[code])
      end
      
      info[:suffix] = true if info[:suffix].nil? && (info[:code] == info[:symbol]) && !info[:code].nil?
      info[:space]  = true if info[:space].nil?  && info[:suffix]
      info[:digits] = -Math.log10(info[:round]).floor if info[:digits].nil?
      
      info
    end
    
    # Formats a numeric value as a nice currency string in UTF-8 encoding.
    # +object+ is the model object carrying the value (used to determine the currency).
    def format_value(object, value)
      info = currency_info_for(object)
      puts info.inspect
      
      # FIXME: take locale into account
      value = "%.#{info[:digits]}f" % value
      while value.sub!(/(\d+)(\d\d\d)/,'\1,\2'); end
      if info[:space]
        info[:suffix] ? "#{value} #{info[:symbol]}" : "#{info[:symbol]} #{value}"
      else
        info[:suffix] ? "#{value}#{info[:symbol]}" : "#{info[:symbol]}#{value}"
      end
    end
  end
end