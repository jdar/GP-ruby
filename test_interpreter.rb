require 'test/unit'
require 'interpreter'

class MultiStack
  module Operations
    module_function # like 'private', but creates singleton-like method calling    
    def add(a,b);          puts "#{a} + #{b} = #{a+b}";  a + b    end
    def subtract(a,b);     puts "#{a} - #{b} = #{a+b}";  a - b    end
  end
end
class Interpreter
  def test_run
    @sequence.reverse.each do |arg|
      append_to_stack(arg)
    end
  end
end


class TestCaseInterpreter < Test::Unit::TestCase
  def test_program_stacks_ints
    interpreter = Interpreter.new(:sequence=>[1,2,3,4])
    assert_equal [4,3,2,1], interpreter.stack[Fixnum]
  end
  
  def test_program_adds_ints
    interpreter = Interpreter.new(:sequence=>[1,2,"add",3,4])
    assert_equal [7,2,1], interpreter.stack[Fixnum]
  end
  
  def test_program_ignores_operations_when_insufficent_args
    interpreter = Interpreter.new(:sequence=>[1,2,"add"])
    assert_equal [2,1], interpreter.stack[Fixnum]
  end
  
  def test_program_should_fail_when_args_not_defined_in_operations_module
    assert_raises NameError do
      interpreter = Interpreter.new(:sequence=>[1,2,"not_a_valid_operation"])
    end
  end
  
  def test_program_accepts_procs
    interpreter = Interpreter.new(:sequence=>[1,2, Proc.new{3},4,5])
    assert_equal [5,4,3,2,1], interpreter.stack[Fixnum]
  end
  
end

