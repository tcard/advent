/*
--- Part Two ---

Ding! The "fasten seat belt" signs have turned on. Time to find your seat.

It's a completely full flight, so your seat should be the only missing boarding
pass in your list. However, there's a catch: some of the seats at the very front
and back of the plane don't exist on this aircraft, so they'll be missing from
your list as well.

Your seat wasn't at the very front or back, though; the seats with IDs +1 and -1
from yours will be in your list.

What is the ID of your seat?
*/

package main

import (
	"bufio"
	"fmt"
	"os"
)

func solve(next func() (line string, ok bool)) int {
	const (
		rows     = 128
		columns  = 8
		rowsPart = 7
	)

	idFound := make([]bool, rows*columns)
	for line, ok := next(); ok; line, ok = next() {
		row := followPartitioning(line[:rowsPart], rows, 'F', 'B')
		col := followPartitioning(line[rowsPart:], columns, 'L', 'R')
		id := row*8 + col
		idFound[id] = true
	}
	for id := 1; id < len(idFound)-1; id++ {
		if !idFound[id] && idFound[id-1] && idFound[id+1] {
			return id
		}
	}
	panic("bad input")
}

func followPartitioning(partitioning string, max int, lower, upper rune) int {
	min := 0
	max -= 1 // length -> index
	n := 0
	for _, c := range partitioning {
		shift := (max - min + 1) / 2
		switch c {
		case lower:
			max -= shift
			n = max
		case upper:
			min += shift
			n = min
		}
	}
	return n
}

func main() {
	lines := bufio.NewScanner(os.Stdin)
	solution := solve(func() (line string, ok bool) {
		ok = lines.Scan()
		return lines.Text(), ok
	})

	fmt.Println(solution)
}
