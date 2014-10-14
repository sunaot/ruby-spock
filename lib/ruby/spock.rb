require 'power_assert'

module Ruby
  module Spock
    def spec(description, definition = nil, &proc_definition)
      raise ArgumentError if [ definition, proc_definition ].all? {|d| d.nil? }
      if definition.nil?
        spec_runner(description, proc_definition)
      else
        spec_runner(description, definition)
      end
    end

    private
    def spec_runner(description, definition)
      s = Specification.new
      d = Definition.new(s)
      d.instance_eval(&definition)

      puts description
      s.examples.each do |args|
        if s.expectation.call(*args)
          print '.'
        else
          print 'F'
        end
      end
      print "\n"
    end

    class Specification
      attr_accessor :expectation, :examples
    end

    class Definition
      attr_reader :spec
      def initialize(specification)
        @spec = specification
      end

      def expect(expectation)
        spec.expectation = expectation
      end

      def assert(&blk)
        ::PowerAssert.start(blk, assertion_method: __method__) do |pa|
          result = pa.yield
          message = pa.message_proc.()
          puts message unless result
          result
        end
      end

      def where(examples)
        spec.examples = examples
      end
    end
  end
end

class Foo
  extend  Ruby::Spock

  spec 'maximum of two numbers', ->(*) {
    expect ->(a, b, c) {
      assert { [a, b].max == c }
    }
    where [
      # a | b | c
      [ 1 , 3 , 3 ],
      [ 7 , 4 , 4 ],
      [ 0 , 0 , 0 ],
    ]
  }

  spec 'minimum of two numbers' do
    expect ->(a, b, c) { [a, b].min == c }
    where [
      # a | b | c
      [ 1 , 3 , 1 ],
      [ 7 , 4 , 4 ],
      [ 0 , 0 , 1 ],
    ]
  end
end
