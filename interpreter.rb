require 'rubygems'
require 'json'
require 'ruby-debug'


class MultiStack < Hash 
#   has an efficient type-aware stack already been implemented?

  # MYTODO: make this be type-agnostic (i.e., get rid of self[Fixnum], and auto-detect types) 
  # need an api concept. Maybe I should inherit from Array instead.  
  
  def stack; self end
  
  def call_proc(proc)
    arity = proc.arity
    return if self[Fixnum].size < arity

    self[Fixnum] << proc.call(*self[Fixnum].slice!(-arity,arity))
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
      manipulate_stack(arg)
    end
  end

  def manipulate_stack(arg)
    @stack.call_proc case arg
     when "X";        x
     when String;     MultiStack::Operations.method(arg).to_proc
     when Proc;       arg
     else
        return @stack[arg.class] << arg
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
class Proc
  attr_accessor :type_sig
  def initialize
    @type_sig = (1..arity).collect{Integer}
    super
  end
end

