/*
--- Day 7: Handy Haversacks ---

You land at the regional airport in time for your next flight. In fact, it looks
like you'll even have time to grab some food: all flights are currently delayed
due to issues in luggage processing.

Due to recent aviation regulations, many rules (your puzzle input) are being
enforced about bags and their contents; bags must be color-coded and must
contain specific quantities of other color-coded bags. Apparently, nobody
responsible for these regulations considered how long they would take to
enforce!

For example, consider the following rules:

light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.

These rules specify the required contents for 9 bag types. In this example,
every faded blue bag is empty, every vibrant plum bag contains 11 bags (5 faded
blue and 6 dotted black), and so on.

You have a shiny gold bag. If you wanted to carry it in at least one other bag,
how many different bag colors would be valid for the outermost bag? (In other
words: how many colors can, eventually, contain at least one shiny gold bag?)

In the above rules, the following options would be available to you:

A bright white bag, which can hold your shiny gold bag directly.

A muted yellow bag, which can hold your shiny gold bag directly, plus some other
bags.

A dark orange bag, which can hold bright white and muted yellow bags, either of
which could then hold your shiny gold bag.

A light red bag, which can hold bright white and muted yellow bags, either of
which could then hold your shiny gold bag.

So, in this example, the number of bag colors that can eventually contain at
least one shiny gold bag is 4.

How many bag colors can eventually contain at least one shiny gold bag? (The
list of rules is quite long; make sure you get all of it.)
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
	return len(rules.ContainersOfColor("shiny gold"))
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

func (r bagRules) ContainersOfColor(target string) []string {
	var containers []string
	for root, _ := range r {
		if r.containsFrom(root, target) { // could memoize
			containers = append(containers, root)
		}
	}
	return containers
}

func (r bagRules) containsFrom(from, target string) bool {
	for contained, _ := range r[from] {
		if contained == target {
			return true
		}
		if r.containsFrom(contained, target) {
			return true
		}
	}
	return false
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
		expected: 4,
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
