/*
--- Part Two ---

It's getting pretty expensive to fly these days - not because of ticket prices,
but because of the ridiculous number of bags you need to buy!

Consider again your shiny gold bag and the rules from the above example:

faded blue bags contain 0 other bags.

dotted black bags contain 0 other bags.

vibrant plum bags contain 11 other bags: 5 faded blue bags and 6 dotted black
bags.

dark olive bags contain 7 other bags: 3 faded blue bags and 4 dotted black bags.

So, a single shiny gold bag must contain 1 dark olive bag (and the 7 bags within
it) plus 2 vibrant plum bags (and the 11 bags within each of those): 1 + 1*7 + 2
+ 2*11 = 32 bags!

Of course, the actual rules have a small chance of going several levels deeper
than this example; be sure to count all of the bags, even if the nesting becomes
topologically impractical!

Here's another example:

shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.

In this example, a single shiny gold bag must contain 126 other bags.

How many individual bags are required inside your single shiny gold bag?
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
	rules := bagRules{}
	for line, ok := next(); ok; line, ok = next() {
		rules.Add(line)
	}
	return rules.MustContain("shiny gold")
}

// bagRules encodes "bag of color X can contain N bags of color Y" as
// map[X]map[Y]N.
type bagRules map[string]map[string]int

func (r bagRules) Add(rule string) {
	parts := strings.Split(rule, " bags contain ")
	container, contained := parts[0], parts[1]

	m, ok := r[container]
	if !ok {
		m = map[string]int{}
		r[container] = m
	}

	if contained == "no other bags" {
		return
	}

	for _, c := range strings.Split(contained, ", ") {
		parts := strings.Split(c, " ")
		n, _ := strconv.Atoi(parts[0])
		color := parts[1] + " " + parts[2]
		m[color] = n
	}
}

func (r bagRules) MustContain(root string) int {
	count := 0
	for contained, amount := range r[root] {
		count += amount + amount*r.MustContain(contained)
	}
	return count
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
			`light red bags contain 1 bright white bag, 2 muted yellow bags.`,
			`dark orange bags contain 3 bright white bags, 4 muted yellow bags.`,
			`bright white bags contain 1 shiny gold bag.`,
			`muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.`,
			`shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.`,
			`dark olive bags contain 3 faded blue bags, 4 dotted black bags.`,
			`vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.`,
			`faded blue bags contain no other bags.`,
			`dotted black bags contain no other bags.`,
		},
		expected: 32,
	}, {
		in: []string{
			`shiny gold bags contain 2 dark red bags.`,
			`dark red bags contain 2 dark orange bags.`,
			`dark orange bags contain 2 dark yellow bags.`,
			`dark yellow bags contain 2 dark green bags.`,
			`dark green bags contain 2 dark blue bags.`,
			`dark blue bags contain 2 dark violet bags.`,
			`dark violet bags contain no other bags.`,
		},
		expected: 126,
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
