module Invoicing
  # == General notes on currency precision and rounding
  #
  # It is important to deal carefully with rounding errors in accounts. If the figures don't add up exactly,
  # you may have to pay for expensive accountant hours while they try to find out where the missing pennies or
  # cents have gone -- better to avoid this trouble from the start. Because of this, it is strongly recommended
  # that you use fixed-point or decimal datatypes to store any sort of currency amounts, never floating-point
  # numbers.
  #
  # Keep in mind that not all currency subdivide their main unit into 100 smaller units; storing four digits
  # after the decimal point should be enough to allow you to expand into other currencies in future. Also leave
  # enough headroom in case you ever need to use an inflated currency. For example,
  # if you are using MySQL, <tt>decimal(20,4)</tt> may be a good choice for all your columns which store
  # monetary amounts. The extra few bytes aren't going to cost you anything.
  #
  # On the other hand, it doesn't usually make sense to store monetary values with a higher precision than is
  # conventional for a particular currency (usually this is related to the value of the smallest coin in
  # circulation, but conventions may differ). For example, if your currency rounds to two decimal places, then
  # you should also round every monetary amount to two decimal places before storing it. If you store values
  # at a higher precision than you display, your numbers may appear to not add up correctly. It is better to
  # accept a slight loss of precision than to cause such confusion.
  #
  # == Using +attr_currency_rounding+
  #
  # This module simplifies model objects which need to store monetary values, by automatically taking care
  # of currency rounding conventions.
  module CurrencyRounding
    module ActMethods
      def attr_currency_rounding
        
      end
    end
  end
end