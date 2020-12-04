/*
--- Day 3: Toboggan Trajectory ---

With the toboggan login problems resolved, you set off toward the airport. While
travel by toboggan might be easy, it's certainly not safe: there's very minimal
steering and the area is covered in trees. You'll need to see which angles will
take you near the fewest trees.

Due to the local geology, trees in this area only grow on exact integer
coordinates in a grid. You make a map (your puzzle input) of the open squares
(.) and trees (#) you can see. For example:

..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#

These aren't the only trees, though; due to something you read about once
involving arboreal genetics and biome stability, the same pattern repeats to the
right many times:

..##.........##.........##.........##.........##.........##.......  --->
#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
.#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
.#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
.#........#.#........#.#........#.#........#.#........#.#........#
#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
#...##....##...##....##...##....##...##....##...##....##...##....#
.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

You start on the open square (.) in the top-left corner and need to reach the
bottom (below the bottom-most row on your map).

The toboggan can only follow a few specific slopes (you opted for a cheaper
model that prefers rational numbers); start by counting all the trees you would
encounter for the slope right 3, down 1:

From your starting position at the top-left, check the position that is right 3
and down 1. Then, check the position that is right 3 and down 1 from there, and
so on until you go past the bottom of the map.

The locations you'd check in the above example are marked here with O where
there was an open square and X where there was a tree:

..##.........##.........##.........##.........##.........##.......  --->
#..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
.#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
.#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
.#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
.#........#.#........X.#........#.#........#.#........#.#........#
#.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
#...##....##...##....##...#X....##...##....##...##....##...##....#
.#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

In this example, traversing the map using this slope would cause you to
encounter 7 trees.

Starting at the top-left corner of your map and following a slope of right 3
and down 1, how many trees would you encounter?
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

	treesFound := 0
	x, y := 0, 0
	for hasTree, ok := m.cell(x, y); ok; hasTree, ok = m.cell(x, y) {
		if hasTree {
			treesFound++
		}
		x += 3
		y += 1
	}
	return treesFound
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
		expected: 7,
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
