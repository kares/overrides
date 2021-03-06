require 'overrides/version'

# Allows for an #overrides annotation for your methods.
#
# This might help during refactoring (method renaming) to assure methods
# expected to be overriding another (and calling super) fail early during
# definition time instead of when called.
#
# Usage :
#
#     class Message
#       extend Overrides
#
#       def do_send; end
#       def sent_at; end
#       def reply?; end
#     end
#
#     class Notice < Message
#       overrides
#       def do_send; super; end
#
#       def reply?; nil; end
#       def sent_at; nil; end
#
#       overrides :reply?, :sent_at
#     end
#
#
# Without arguments (before method) works with singleton methods as well :
#
#     class Message
#       extend Overrides
#
#       def self.deliver(msg); end
#     end
#
#     class Notice < Message
#       overrides
#       def self.deliver(msg); end
#     end
#
# To hook it up for all classes/modules, simply do a :
#
#    Object.extend Overrides
#
# @author kares
#
module Overrides

  # Custom (missing method error) raised from {#overrides}.
  class Error < NoMethodError; end

  def overrides(*names)
    if names.empty? # next method def - singleton or instance
      @_override = true
    else
      names.each do |name| # only for instance methods
        unless Overrides.includes_method? self.instance_methods(false), name
          msg = "(instance) method #{name.inspect} not found in "
          raise NoMethodError,
            msg << ( self.is_a?(Class) ? 'class ' : 'module ' ) << self.inspect
        end
        unless Overrides.overriden?(self, name)
          raise Error, "previous (instance) method #{name.inspect} not found"
        end
      end
    end
  end

  # @private
  def method_added(name)
    return super unless (@_override ||= nil); @_override = false
    unless Overrides.overriden?(self, name, true)
      raise Error, "previous (instance) method #{name.inspect} not found"
    end
    super
  end

  # @private
  def singleton_method_added(name)
    return super unless (@_override ||= nil); @_override = false
    unless Overrides.overriden?(self, name, false)
      raise Error, "previous singleton method #{name.inspect} not found"
    end
    super
  end

  # Checks if a method was previously available in the given module's method
  # resolution chain. Assumes instance methods by default.
  def self.overriden?(klass, method, instance = true)
    if instance
      klass.included_modules.each do |mod|
        return true if includes_method? mod.instance_methods(true), method
      end
      return false unless klass.is_a?(Class) # "only" a Module ...
      return includes_method? klass.superclass.instance_methods(true), method
    else
      (class << klass; self; end).included_modules.each do |mod|
        return true if includes_method? mod.instance_methods(true), method
      end
      return false unless klass.is_a?(Class) # "only" a Module ...
      return includes_method? klass.superclass.methods(true), method
    end
  end

  # @private
  def self.includes_method?(methods, name)
    methods.include? name
  end

  # @private
  def self.includes_method?(methods, name)
    methods.include? name.to_s
  end if RUBY_VERSION < '1.9'

end
