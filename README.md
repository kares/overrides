# Overrides

An #overrides annotation for your (Ruby) methods.

Inspired by Java's [@Override][1].


## Install

    $ gem install overrides

or add this line to your application's *Gemfile* (and `bundle`) :

    gem 'overrides'

optionally add  `:require => 'overrides/for_all'` to have `overrides` available
in all classes/modules as a built-in (singleton) method.


## Usage

Let's have a base class with `Overrides` pulled in :

    class Message
      extend Overrides

      def self.deliver(msg); end

      def do_send; end
      def sent_at; end
      def reply?; end
    end

a notice would be a message sub-type, note how `overrides` gets used :

    class Notice < Message
      overrides
      def do_send; super; end

      def reply?; nil; end
      def sent_at; nil; end

      overrides :reply?, :sent_at
    end

 without args (before method) works with singleton methods as well :

    class Notice < Message
      overrides
      def self.deliver(msg); end
    end

**NOTE:** there's no global name-space pollution by default, thus you'll need
to hook up the `Overrides` module (or extend `Object` to pull it in for all).

### "Java"

Here's how you use it with JRuby to "annotate" method overrides :

    require 'overrides/for_all'

    class NonEmptyList < java.util.ArrayList

      def initialize
        super(); add nil
      end

      overrides
      def clear; super; add nil; end

      def isEmpty; false; end
      overrides :isEmpty

    end


## Copyright

Copyright (c) 2013 [Karol Bucek](http://kares.org).
See LICENSE.txt (http://en.wikipedia.org/wiki/MIT_License) for details.

[0]: https://github.com/kares/overrides
[1]: http://docs.oracle.com/javase/7/docs/api/java/lang/Override.html