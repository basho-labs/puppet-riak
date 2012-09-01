module Puppet::Parser::Util
  module InstanceMethods
    def convert(value)
      case value
      when ::String
        if value =~ /^[0-9]+$/ then
          ::Puppet::Parser::Util::Value.new(Integer(value))
        else
          ::Puppet::Parser::Util::String.new(value)
        end
      when ::Array
        ::Puppet::Parser::Util::Array.new(value)
      when ::Hash
        ::Puppet::Parser::Util::Hash.new(value)
      when ::TrueClass
        ::Puppet::Parser::Util::Value.new("true")
      when ::FalseClass
        ::Puppet::Parser::Util::Value.new("false")
      when ::NilClass
        ::Puppet::Parser::Util::Value.new("null")
      else
        ::Puppet::Parser::Util::Value.new(value)
      end
    end

    def indent(level)
      "\t" * level
    end
  end
  class Value
    def initialize(val)
      @val = val
    end

    def to_s
      @val
    end

    def pp(level=0)
      to_s
    end
  end

  class String
    def initialize(str)
      @str = str
    end

    def to_s
      case @str
      when /^__binary_(.*)/
        to_binary($1)
      when /^__string_(.*)/
        to_string($1)
      when /^__atom_(.*)/
        to_atom($1)
      else
        to_string(@str)
      end
    end

    def pp(level=0)
      to_s
    end

    private

    def to_binary(str)
      "<<\"#{str}\">>"
    end

    def to_string(str)
      "\"#{str}\""
    end

    def to_atom(str)
      case str
      when /^[a-z][\w@]*$/
        str
      else
        "'#{str}'"
      end
    end
  end

  class Array
    include InstanceMethods

    def initialize(arr)
      case arr[0]
      when "__list"
        @type = :list
        @values = arr[1..-1].map { |e| convert(e) }
      when "__tuple"
        @type = :tuple
        @values = arr[1..-1].map { |e| convert(e) }
      else
        @type = :list
        @values = arr.map { |e| convert(e) }
      end
    end

    def to_s
      values1 = @values.map { |v| v.to_s }
      case @type
      when :tuple
        "{#{values1.join(", ")}}"
      else
        "[#{values1.join(", ")}]"
      end
    end

    def pp(level=0)
      case @type
      when :tuple
        values1 = @values.map { |v| v.pp(level+1) }
        "{#{values1.join(", ")}}"
      else
        values1 = @values.map { |v| "\n#{indent(level+1)}#{v.pp(level+1)}" }
        "[#{values1.join(",")}\n#{indent(level)}]"
      end
    end
  end

  class Hash
    include InstanceMethods

    def initialize(hsh)
      @data = []
      hsh.sort.map do |k,v|
        tmp = ''
        if k.to_s.start_with?"__string_" then
          tmp = k.to_s
        else
          tmp = '__atom_' + k.to_s
        end
        k1 = ::Puppet::Parser::Util::String.new(tmp)
        v1 = convert(v)
        @data << [k1, v1]
      end
    end

    def to_s
      values = @data.map do |k,v|
        "{#{k.to_s}, #{v.to_s}}"
      end
      "[#{values.join(", ")}]"
    end

    def pp(level=0)
      values = @data.map do |k,v|
        "\n#{indent(level+1)}{#{k.to_s}, #{v.pp(level+1)}}"
      end
      "[#{values.join(",")}\n#{indent(level)}]"
    end
  end

  class Config
    include InstanceMethods

    def initialize(value)
      @config = convert(value)
    end

    def to_s
      @config.to_s + "."
    end

    def pp(level=0)
      @config.pp(level) + "."
    end
  end

  class Args
    def initialize(args)
      @args = args
    end

    def expand(k1, v1)
      case v1
      when ::Hash
        v1.sort.map { |k2, v2| expand("#{k1} #{k2}", v2) }
      else
        "#{k1} #{v1}"
      end
    end

    def to_a
      @args.sort.map { |k, v| expand(k, v) }.flatten
    end

    def to_s
      to_a.join(" ")
    end

    def pp(level=0)
      to_a.join("\n")
    end
  end
end