// --- Part Two ---

// While it appears you validated the passwords correctly, they don't seem to be
// what the Official Toboggan Corporate Authentication System is expecting.

// The shopkeeper suddenly realizes that he just accidentally explained the
// password policy rules from his old job at the sled rental place down the
// street! The Official Toboggan Corporate Policy actually works a little
// differently.

// Each policy actually describes two positions in the password, where 1 means
// the first character, 2 means the second character, and so on. (Be careful;
// Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of
// these positions must contain the given letter. Other occurrences of the
// letter are irrelevant for the purposes of policy enforcement.

// Given the same example list from above:

//     1-3 a: abcde is valid: position 1 contains a and position 3 does not. 1-3
//     b: cdefg is invalid: neither position 1 nor position 3 contains b. 2-9 c:
//     ccccccccc is invalid: both position 2 and position 9 contain c.

// How many passwords are valid according to the new interpretation of the
// policies?

package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

func solve(next func() (line string, ok bool)) int {
	valid := 0
	for line, ok := next(); ok; line, ok = next() {
		pass := parsePassword(line)
		found := 0
		for _, validPos := range pass.policy.validPositions {
			if pass.password[validPos-1:validPos] == pass.policy.letter {
				found++
			}
		}
		if found == 1 {
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
	letter         string
	validPositions []int
}

var passwordRgx = regexp.MustCompile(`^([0-9]+)\-([0-9]+) (.): (.*)$`)

func parsePassword(s string) password {
	m := passwordRgx.FindStringSubmatch(s)
	return password{
		policy: passwordPolicy{
			validPositions: []int{mustAtoi(m[1]), mustAtoi(m[2])},
			letter:         m[3],
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
		expected: 1,
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
