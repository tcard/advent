# --- Day 8: I Heard You Like Registers ---

# You receive a signal directly from the CPU. Because of your recent assistance
# with jump instructions, it would like you to compute the result of a series of
# unusual register instructions.

# Each instruction consists of several parts: the register to modify, whether to
# increase or decrease that register's value, the amount by which to increase or
# decrease it, and a condition. If the condition fails, skip the instruction
# without modifying the register. The registers all start at 0. The instructions
# look like this:

# b inc 5 if a > 1
# a inc 1 if b < 5
# c dec -10 if a >= 1
# c inc -20 if c == 10
# These instructions would be processed as follows:

# Because a starts at 0, it is not greater than 1, and so b is not modified.

# a is increased by 1 (to 1) because b is less than 5 (it is 0).

# c is decreased by -10 (to 10) because a is now greater than or equal to 1 (it
# is 1).

# c is increased by -20 (to -10) because c is equal to 10.

# After this process, the largest value in any register is 1.

# You might also encounter <= (less than or equal to) or != (not equal to).
# However, the CPU doesn't have the bandwidth to tell you what all the registers
# are named, and leaves that to you to determine.

# What is the largest value in any register after completing the instructions in
# your puzzle input?

enum Op
  Inc
  Dec

  def eval(lhs, rhs)
    case self
    when Inc
      lhs + rhs
    when Dec
      lhs - rhs
    else
      raise "unreachable"
    end
  end
end

enum CondOp
  Eq
  Neq
  Gt
  Lt
  GtEq
  LtEq

  def eval(lhs, rhs)
    case self
    when Eq
      lhs == rhs
    when Neq
      lhs != rhs
    when Gt
      lhs > rhs
    when Lt
      lhs < rhs
    when GtEq
      lhs >= rhs
    when LtEq
      lhs <= rhs
    else
      raise "unreachable"
    end
  end
end

record Cond,
  register : String,
  op : CondOp,
  operand : Int32 do
  def eval(registers)
    @op.eval(registers.fetch(@register, 0), @operand)
  end
end

record Instruction,
  register : String,
  op : Op,
  operand : Int32,
  cond : Cond do
  def eval(registers)
    if @cond.eval(registers)
      registers[@register] = @op.eval(registers.fetch(@register, 0), @operand)
    end
  end
end

def largest_value_in_register(instructions)
  registers = {} of String => Int32

  instructions.each do |instr|
    instr.eval(registers)
  end

  biggest = nil.as(Int32 | Nil)

  registers.each_value do |value|
    if biggest.nil? || (value.nil? ? false : value > biggest)
      biggest = value
    end
  end

  biggest
end

def run_tests
  [
    {[
      {"b", Op::Inc, 5, "a", CondOp::Gt, 1},
      {"a", Op::Inc, 1, "b", CondOp::Lt, 5},
      {"c", Op::Dec, -10, "a", CondOp::GtEq, 1},
      {"c", Op::Inc, -20, "c", CondOp::Eq, 10},
    ], 1},
  ].map do |test_case|
    input, expected = test_case
    instructions = input.map do |instr|
      Instruction.new(instr[0], instr[1], instr[2], Cond.new(instr[3], instr[4], instr[5]))
    end
    got = largest_value_in_register(instructions)

    if expected != got
      raise "expected #{expected}, got #{got}: #{input}"
    end
  end
end

def process_input
  instructions = [] of Instruction
  regexp = /^(?<register>[a-z]+) (?<op>[^\\w]+) (?<operand>[^\\w]+) if (?<cond_register>[a-z]+) (?<cond_op>[^\\w]+) (?<cond_operand>[^\\w]+)$/

  while true
    line = gets
    if line.nil?
      break
    end

    match = regexp.match(line)
    if match.nil?
      raise "malformed instruction: #{line}"
    end

    instructions << Instruction.new(
      match["register"],
      case match["op"]
      when "inc"
        Op::Inc
      when "dec"
        Op::Dec
      else
        raise "unknown operand: #{match["op"]}"
      end,
      match["operand"].to_i32,
      Cond.new(
        match["cond_register"],
        case match["cond_op"]
        when "=="
          CondOp::Eq
        when "!="
          CondOp::Neq
        when ">"
          CondOp::Gt
        when "<"
          CondOp::Lt
        when ">="
          CondOp::GtEq
        when "<="
          CondOp::LtEq
        else
          raise "unknown conditional operand: #{match["cond_op"]}"
        end,
        match["cond_operand"].to_i32
      ))
  end

  puts largest_value_in_register(instructions)
end

run_tests
process_input
