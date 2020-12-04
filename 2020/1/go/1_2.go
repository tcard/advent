package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

// --- Part Two ---

// The Elves in accounting are thankful for your help; one of them even offers
// you a starfish coin they had left over from a past vacation. They offer you a
// second one if you can find three numbers in your expense report that meet the
// same criteria.

// Using the above example again, the three entries that sum to 2020 are 979,
// 366, and 675. Multiplying them together produces the answer, 241861950.

// In your expense report, what is the product of the three entries that sum to
// 2020?

func solve(next func() (n int, ok bool)) int {
	var numbers []int
	for a, ok := next(); ok; a, ok = next() {
		for bi, b := range numbers {
			for ci, c := range numbers {
				if ci == bi {
					continue
				}
				if a+b+c == 2020 {
					return a * b * c
				}
			}
		}
		numbers = append(numbers, a)
	}
	panic("bad input")
}

func main() {
	test()

	lines := bufio.NewScanner(os.Stdin)
	solution := solve(func() (n int, ok bool) {
		if !lines.Scan() {
			return 0, false
		}
		n, _ = strconv.Atoi(lines.Text())
		return n, true
	})
	fmt.Println(solution)
}

func test() {
	for ci, c := range []struct {
		in       []int
		expected int
	}{{
		in: []int{
			1721,
			979,
			366,
			299,
			675,
			1456,
		},
		expected: 241861950,
	}} {
		i := -1
		solution := solve(func() (n int, ok bool) {
			i++
			if i >= len(c.in) {
				return 0, false
			}
			return c.in[i], true
		})
		if c.expected != solution {
			panic(fmt.Errorf("%d: expected %d, got %d", ci, c.expected, solution))
		}
	}
}
