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
    def x; @x || lambda{|x| x } end
    def x=(x); @x = (x.is_a?(Proc) ? x : proc{x}) end
  end
  def self.function_list; %w(add add ERF ERF X) end
  
  attr_accessor :sequence, :stack
  
  
  
  def solve
    self.stack[Fixnum].last
  end
  def mutate
    new_sequence = self.sequence
    new_sequence[self.splice_index] = generate_sequence(1)
    self.class.new :sequence => new_sequence.flatten
  end
  def crossover(other)
    return self if other.nil?
    
    i1 = rand(self.sequence.length - 1) # self.splice_index
    i2 = rand(other.sequence.length - 1)
        
    m1, m2 = self.seg(i1)
    f1, f2 = other.seg(i2)    
    [
      self.class.new(:sequence=> m1 + f2 ),
      self.class.new(:sequence=> f1 + m2 )
    ]
    
  end
  
  
  def x; self.class.x end # call delegate
  def x=(x); self.class.x = x end
  def call(x=[]); 
    self.class.x = (block_given? ? proc{x} : [*x].first) # currently only handle one block
    self.class.new(:sequence=>sequence).solve
  end

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
  
  def solve
    puts "SOLVE: pops last from Fixnum stack. Redefine @integer.solve() for other response."
    self.stack[Fixnum].last #.inject(0) {|accum,i| accum += i }
  end
  
  #see tests
  def segment(first_index,last_index = nil)
    #convenience recursion
    return [
               self.seg(          0, first_index),
               self.seg(first_index,         -1)
            ] if last_index.nil?
    
    #segment
    last_index ||= -1
    slice_length = if last_index < 0;      (sequence.size - first_index) + last_index
                  else;                    last_index - first_index + 1
                   end

    return self.sequence.slice first_index, slice_length if first_index == 0
    self.sequence.slice first_index + 1, slice_length
  end
  alias seg segment
  
  def splice_index
    rand(self.sequence.length - 1)
  end
     
end
class Proc
  attr_accessor :type_sig
  def initialize
    @type_sig = (1..arity).collect{Fixnum}
    super
  end
end

