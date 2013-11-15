require 'overrides/version'

# Allows for an #overrides annotation for your methods.
#
# Thus might help you e.g. during refactoring (method renaming) to assure methods
# expected to call a super will fail early during def time instead of when called.
#
# Sample :
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
# Without arguments works with singleton methods as well :
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

  Error = NoMethodError

  def overrides(*names)
    if names.empty? # next method
      @_override = true
    else
      names.each do |name|
        unless Overrides.overriden?(self, name)
          raise Error, "previous (instance) method #{name.inspect} not found"
        end
      end
    end
  end

  def method_added(name)
    return super unless (@_override ||= nil); @_override = false
    unless Overrides.overriden?(self, name, true)
      raise Error, "previous (instance) method #{name.inspect} not found"
    end
    super
  end

  def singleton_method_added(name)
    return super unless (@_override ||= nil); @_override = false
    unless Overrides.overriden?(self, name, false)
      raise Error, "previous singleton method #{name.inspect} not found"
    end
    super
  end

  def self.overriden?(klass, method, instance = true)
    if instance
      klass.included_modules.each do |mod|
        return true if mod.instance_methods(true).include? method
      end
      return false unless klass.is_a?(Class) # "only" a Module ...
      return klass.superclass.instance_methods(true).include? method
    else
      (class << klass; self; end).included_modules.each do |mod|
        return true if mod.instance_methods(true).include? method
      end
      return false unless klass.is_a?(Class) # "only" a Module ...
      return klass.superclass.methods(true).include? method
    end
  end

end
