# --- Part Two ---

# To be safe, the CPU also needs to know the highest value held in any register
# during this process so that it can decide how much memory to allocate to these
# operations. For example, in the above instructions, the highest value ever
# held was 10 (in register c after the third instruction was evaluated).

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
      value = @op.eval(registers.fetch(@register, 0), @operand)
      registers[@register] = value
      return value
    end
  end
end

def largest_value_ever_in_register(instructions)
  registers = {} of String => Int32
  biggest = nil.as(Int32 | Nil)

  instructions.each do |instr|
    value = instr.eval(registers)
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
    ], 10},
  ].map do |test_case|
    input, expected = test_case
    instructions = input.map do |instr|
      Instruction.new(instr[0], instr[1], instr[2], Cond.new(instr[3], instr[4], instr[5]))
    end
    got = largest_value_ever_in_register(instructions)

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

  puts largest_value_ever_in_register(instructions)
end

run_tests
process_input
