/*
--- Part Two ---

After some careful analysis, you believe that exactly one instruction is
corrupted.

Somewhere in the program, either a jmp is supposed to be a nop, or a nop is
supposed to be a jmp. (No acc instructions were harmed in the corruption of this
boot code.)

The program is supposed to terminate by attempting to execute an instruction
immediately after the last instruction in the file. By changing exactly one jmp
or nop, you can repair the boot code and make it terminate correctly.

For example, consider the same program from above:

nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6

If you change the first instruction from nop +0 to jmp +0, it would create a
single-instruction infinite loop, never leaving that instruction. If you change
almost any of the jmp instructions, the program will still eventually find
another jmp instruction and loop forever.

However, if you change the second-to-last instruction (from jmp -4 to nop -4),
the program terminates! The instructions are visited in this order:

nop +0  | 1
acc +1  | 2
jmp +4  | 3
acc +3  |
jmp -3  |
acc -99 |
acc +1  | 4
nop -4  | 5
acc +6  | 6

After the last instruction (acc +6), the program terminates by attempting to run
the instruction below the last instruction in the file. With this change, after
the program terminates, the accumulator contains the value 8 (acc +1, acc +1,
acc +6).

Fix the program so that it terminates normally by changing exactly one jmp (to
nop) or nop (to jmp). What is the value of the accumulator after the program
terminates?
*/

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func solve(next func() (line string, ok bool)) int {
	type instruction struct {
		op  string
		arg int
	}
	var program []instruction

	for line, ok := next(); ok; line, ok = next() {
		parts := strings.Split(line, " ")
		arg, _ := strconv.Atoi(parts[1])
		program = append(program, instruction{op: parts[0], arg: arg})
	}

	type state struct {
		acc, pc int
	}
	trace := []state{{0, 0}}
	lastFixAttemptAt := -1

	deriveSeen := func() []bool {
		seen := make([]bool, len(program))
		for _, s := range trace[:len(trace)-1] { // Skip last; that's _next_ state.
			seen[s.pc] = true
		}
		return seen
	}
	seen := deriveSeen()

	for {
		s := trace[len(trace)-1]
		if s.pc >= len(program) {
			return s.acc
		}

		i := program[s.pc]

		if seen[s.pc] {
			// We found a loop! Now let's go back in our machine's state trace, find a
			// jmp or nop, switch it by its opposite, rerun from that point. If we
			// encounter a loop again, undo the last switch, find the previous jmp or nop,
			// try again, and so on.

			j := lastFixAttemptAt
			if j < 0 {
				// This is the first fix attempt.
				j = len(trace) - 1
			} else {
				// Undo last fix attempt.
				switch s := &program[trace[j].pc]; s.op {
				case "nop":
					s.op = "jmp"
				case "jmp":
					s.op = "nop"
				}
				j--
			}

			// Find and switch the last nop or jmp.
			for {
				switch s := &program[trace[j].pc]; s.op {
				default:
					j--
					continue
				case "nop":
					s.op = "jmp"
				case "jmp":
					s.op = "nop"
				}
				break
			}
			lastFixAttemptAt = j

			// Then, rewind machine state to when we last ran that instruction.
			trace = trace[:j+1]
			seen = deriveSeen()
			continue
		}

		seen[s.pc] = true

		switch i.op {
		case "nop":
			s.pc++
		case "acc":
			s.acc += i.arg
			s.pc++
		case "jmp":
			s.pc += i.arg
		}
		trace = append(trace, s)
	}
}

func main() {
	test()

	lines := bufio.NewScanner(os.Stdin)
	solution := solve(func() (line string, ok bool) {
		ok = lines.Scan()
		return lines.Text(), ok
	})

	fmt.Println(solution)
}

func test() {
	for ci, c := range []struct {
		in       []string
		expected int
	}{{
		in: []string{
			`nop +0`,
			`acc +1`,
			`jmp +4`,
			`acc +3`,
			`jmp -3`,
			`acc -99`,
			`acc +1`,
			`jmp -4`,
			`acc +6`,
		},
		expected: 8,
	}} {
		i := -1
		solution := solve(func() (line string, ok bool) {
			i++
			if i >= len(c.in) {
				return "", false
			}
			return c.in[i], true
		})
		if c.expected != solution {
			panic(fmt.Errorf("%d: expected %d, got %d", ci, c.expected, solution))
		}
	}
}
