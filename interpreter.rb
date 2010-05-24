require 'rubygems'
require 'json'
require 'ruby-debug'
class MultiStack < Hash 
#   has an efficient type-aware stack already been implemented?

  # MYTODO: make this be type-agnostic (i.e., get rid of self[:int], and auto-detect types) 
  # need an api concept. Maybe I should inherit from Array instead.  
  
  def execute_proc(proc)
    arity = proc.arity
    return if self[:int].size < arity

    self[:int] << proc.call(*self[:int].slice!(-arity,arity))
  end
  def execute_operation(operation_name)
    arity = Operations.instance_method(operation_name).arity
    return if self[:int].size < arity

    self[:int] << Operations.send(operation_name, *self[:int].slice!(-arity,arity))
  end
  
  def call(method_or_proc)
    case method_or_proc
      when Proc;  execute_proc(method_or_proc)
      when String; execute_operation(method_or_proc)
    end
  end
    
  module Operations
    module_function # like 'private', but creates singleton-like method calling    
    def add(a,b);      a + b end
    def subtract(a,b); a - b end
  end
end

class Interpreter
  class << self
    attr_accessor :function_list, :x
  end
  def self.function_list; %w(add add ERF ERF X) end
  
  attr_accessor :sequence, :stack
  
  def x; self.class.x || lambda{|x|x} end
  def x=(proc); self.class.x = proc end

  def initialize(attributes = {})
    @sequence = attributes[:sequence] ||= generate_sequence(15)    
    @stack = MultiStack.new {|h,k| h[k] = [] }

    @sequence.reverse.each do |arg|
      append_to_stack(arg)
    end
  end

  def append_to_stack(arg)
    case arg
     when "X";              @stack.call(x)
     when String,Proc;      @stack.call(arg)
     when Numeric;          @stack[:int] << arg 
    end
  end


  
  def generate_sequence(length, return_procs = false)
    (0..length).inject([]) do |sequence, i|
      func_name = self.class.function_list.choice # soon-to-be deprecated; use #sample if ruby 1.9
      sequence << case func_name
      when "ERF";      rand(376)
#      when Proc;      func   #proc  \____ these aren't human readable!
#      when "X";       x      #proc  /
      when "X";        "X"
      else;            func_name
      end
    end
  end 
end

