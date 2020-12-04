// --- Day 2: Password Philosophy ---

// Your flight departs in a few days from the coastal airport; the easiest way
// down to the coast from here is via toboggan.

// The shopkeeper at the North Pole Toboggan Rental Shop is having a bad day.
// "Something's wrong with our computers; we can't log in!" You ask if you can
// take a look.

// Their password database seems to be a little corrupted: some of the passwords
// wouldn't have been allowed by the Official Toboggan Corporate Policy that was
// in effect when they were chosen.

// To try to debug the problem, they have created a list (your puzzle input) xof
// passwords (according to the corrupted database) and the corporate policy when
// that password was set.

// For example, suppose you have the following list:

// 1-3 a: abcde 1-3 b: cdefg 2-9 c: ccccccccc

// Each line gives the password policy and then the password. The password
// policy indicates the lowest and highest number of times a given letter must
// appear for the password to be valid. For example, 1-3 a means that the
// password must contain a at least 1 time and at most 3 times.

// In the above example, 2 passwords are valid. The middle password, cdefg, is
// not; it contains no instances of b, but needs at least 1. The first and third
// passwords are valid: they contain one a or nine c, both within the limits of
// their respective policies.

// How many passwords are valid according to their policies?

package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func solve(next func() (line string, ok bool)) int {
	valid := 0
	for line, ok := next(); ok; line, ok = next() {
		pass := parsePassword(line)
		found := strings.Count(pass.password, pass.policy.letter)
		if found >= pass.policy.min && found <= pass.policy.max {
			valid++
		}
	}
	return valid
}

type password struct {
	policy   passwordPolicy
	password string
}

type passwordPolicy struct {
	letter   string
	min, max int
}

var passwordRgx = regexp.MustCompile(`^([0-9]+)\-([0-9]+) (.): (.*)$`)

func parsePassword(s string) password {
	m := passwordRgx.FindStringSubmatch(s)
	return password{
		policy: passwordPolicy{
			min:    mustAtoi(m[1]),
			max:    mustAtoi(m[2]),
			letter: m[3],
		},
		password: m[4],
	}
}

func mustAtoi(s string) int {
	n, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return n
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
			`1-3 a: abcde`,
			`1-3 b: cdefg`,
			`2-9 c: ccccccccc`,
		},
		expected: 2,
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
