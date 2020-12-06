/*
--- Part Two ---

As you finish the last group's customs declaration, you notice that you misread
one word in the instructions:

You don't need to identify the questions to which anyone answered "yes"; you
need to identify the questions to which everyone answered "yes"!

Using the same example as above:

abc

a
b
c

ab
ac

a
a
a
a

b

This list represents answers from five groups:

In the first group, everyone (all 1 person) answered "yes" to 3 questions: a, b,
and c.

In the second group, there is no question to which everyone answered "yes".

In the third group, everyone answered yes to only 1 question, a. Since some
people did not answer "yes" to b or c, they don't count.

In the fourth group, everyone answered yes to only 1 question, a.

In the fifth group, everyone (all 1 person) answered "yes" to 1 question, b.

In this example, the sum of these counts is 3 + 0 + 1 + 1 + 1 = 6.

For each group, count the number of questions to which everyone answered "yes".
What is the sum of those counts?
*/

package main

import (
	"bufio"
	"fmt"
	"os"
)

func solve(next func() (line string, ok bool)) int {
	sum := 0
	answered := map[rune]int{}
	groupSize := 0
	for {
		line, ok := next()
		if !ok || line == "" {
			for _, c := range answered {
				if c == groupSize {
					sum++
				}
			}

			if !ok {
				break
			} else {
				answered = map[rune]int{}
				groupSize = 0
				continue
			}
		}

		groupSize += 1
		for _, question := range line {
			answered[question] += 1
		}
	}
	return sum
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
			`abc`,
			``,
			`a`,
			`b`,
			`c`,
			``,
			`ab`,
			`ac`,
			``,
			`a`,
			`a`,
			`a`,
			`a`,
			``,
			`b`,
		},
		expected: 6,
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
