/*
--- Part Two ---

Time to check the rest of the slopes - you need to minimize the probability of a
sudden arboreal stop, after all.

Determine the number of trees you would encounter if, for each of the following
slopes, you start at the top-left corner and traverse the map all the way to the
bottom:

    Right 1, down 1. Right 3, down 1. (This is the slope you already checked.)
    Right 5, down 1. Right 7, down 1. Right 1, down 2.

In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s)
respectively; multiplied together, these produce the answer 336.

What do you get if you multiply together the number of trees encountered on each
of the listed slopes?
*/

package main

import (
	"bufio"
	"fmt"
	"os"
)

func solve(next func() (line string, ok bool)) int {
	var m treeMap
	for line, ok := next(); ok; line, ok = next() {
		m.addRow(line)
	}

	type vec2 struct {
		x, y int
	}
	directions := []vec2{
		{1, 1},
		{3, 1},
		{5, 1},
		{7, 1},
		{1, 2},
	}

	treesFoundMultiplied := 1
	for _, d := range directions {
		treesFound := 0
		x, y := 0, 0
		for hasTree, ok := m.cell(x, y); ok; hasTree, ok = m.cell(x, y) {
			if hasTree {
				treesFound++
			}
			x += d.x
			y += d.y
		}
		treesFoundMultiplied *= treesFound
	}

	return treesFoundMultiplied
}

type treeMap struct {
	width int
	rows  [][]bool
}

func (m *treeMap) addRow(row string) {
	m.width = len(row)
	trees := make([]bool, len(row))
	for i, c := range row {
		if c == '#' {
			trees[i] = true
		}
	}
	m.rows = append(m.rows, trees)
}

func (m treeMap) cell(x, y int) (hasTree, exists bool) {
	if y >= len(m.rows) {
		return false, false
	}
	// The map repeats indefinitely on the horizontal axis, so, if we go past
	// the width, wrap around.
	x = x % m.width
	return m.rows[y][x], true
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
			`..##.......`,
			`#...#...#..`,
			`.#....#..#.`,
			`..#.#...#.#`,
			`.#...##..#.`,
			`..#.##.....`,
			`.#.#.#....#`,
			`.#........#`,
			`#.##...#...`,
			`#...##....#`,
			`.#..#...#.#`,
		},
		expected: 336,
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
