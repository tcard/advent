/*
--- Part Two ---

The line is moving more quickly now, but you overhear airport security talking
about how passports with invalid data are getting through. Better add some data
validation, quick!

You can continue to ignore the cid field, but each other field has strict rules
about what values are valid for automatic validation:

    byr (Birth Year) - four digits; at least 1920 and at most 2002.
    iyr (Issue Year) - four digits; at least 2010 and at most 2020.
    eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
    hgt (Height) - a number followed by either cm or in:
        If cm, the number must be at least 150 and at most 193.
        If in, the number must be at least 59 and at most 76.
    hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
    ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
    pid (Passport ID) - a nine-digit number, including leading zeroes.
    cid (Country ID) - ignored, missing or not.

Your job is to count the passports where all required fields are both present
and valid according to the above rules. Here are some example values:

byr valid:   2002
byr invalid: 2003

hgt valid:   60in
hgt valid:   190cm
hgt invalid: 190in
hgt invalid: 190

hcl valid:   #123abc
hcl invalid: #123abz
hcl invalid: 123abc

ecl valid:   brn
ecl invalid: wat

pid valid:   000000001
pid invalid: 0123456789

Here are some invalid passports:

eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007

Here are some valid passports:

pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719

Count the number of valid passports - those that have all required fields and
valid values. Continue to treat cid as optional. In your batch file, how many
passports are valid? */

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func solve(next func() (line string, ok bool)) int {
	newPassport := func() map[string]func(string) (valid bool) {
		return map[string]func(string) (valid bool){
			"byr": func(v string) (valid bool) {
				n, err := strconv.Atoi(v)
				return err == nil && n >= 1920 && n <= 2002
			},
			"iyr": func(v string) (valid bool) {
				n, err := strconv.Atoi(v)
				return err == nil && n >= 2010 && n <= 2020
			},
			"eyr": func(v string) (valid bool) {
				n, err := strconv.Atoi(v)
				return err == nil && n >= 2020 && n <= 2030
			},
			"hgt": func(v string) (valid bool) {
				for _, c := range []struct {
					unit     string
					min, max int
				}{
					{"cm", 150, 193},
					{"in", 59, 76},
				} {
					if strings.HasSuffix(v, c.unit) {
						n, err := strconv.Atoi(v[:len(v)-len(c.unit)])
						return err == nil && n >= c.min && n <= c.max
					}
				}
				return false
			},
			"hcl": func(v string) (valid bool) {
				if !strings.HasPrefix(v, "#") {
					return false
				}
				for _, r := range v[1:] {
					if !((r >= '0' && r <= '9') || (r >= 'a' && r <= 'f')) {
						return false
					}
				}
				return true
			},
			"ecl": func(v string) (valid bool) {
				switch v {
				case "amb", "blu", "brn", "gry", "grn", "hzl", "oth":
					return true
				}
				return false
			},
			"pid": func(v string) (valid bool) {
				n, err := strconv.Atoi(v)
				return err == nil && len(v) == 9 && n >= 0 && n <= 999_999_999
			},
		}
	}
	pendingFields := newPassport()

	valid := 0

	for {
		line, ok := next()
		if !ok || line == "" {
			if len(pendingFields) == 0 {
				valid++
			}
			if !ok {
				break
			} else {
				pendingFields = newPassport()
				continue
			}
		}

		kvs := strings.Split(line, " ")
		for _, kv := range kvs {
			parts := strings.Split(kv, ":")
			k, v := parts[0], parts[1]
			if isValid, ok := pendingFields[k]; ok && isValid(v) {
				delete(pendingFields, k)
			}
		}
	}

	return valid
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
			`eyr:1972 cid:100`,
			`hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926`,
			``,
			`iyr:2019`,
			`hcl:#602927 eyr:1967 hgt:170cm`,
			`ecl:grn pid:012533040 byr:1946`,
			``,
			`hcl:dab227 iyr:2012`,
			`ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277`,
			``,
			`hgt:59cm ecl:zzz`,
			`eyr:2038 hcl:74454a iyr:2023`,
			`pid:3556412378 byr:2007`,
			``,
			`pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980`,
			`hcl:#623a2f`,
			``,
			`eyr:2029 ecl:blu cid:129 byr:1989`,
			`iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm`,
			``,
			`hcl:#888785`,
			`hgt:164cm byr:2001 iyr:2015 cid:88`,
			`pid:545766238 ecl:hzl`,
			`eyr:2022`,
			``,
			`iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719`,
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
