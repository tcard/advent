/*
--- Part Two ---

The final step in breaking the XMAS encryption relies on the invalid number you
just found: you must find a contiguous set of at least two numbers in your list
which sum to the invalid number from step 1.

Again consider the above example:

35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576

In this list, adding up all of the numbers from 15 through 40 produces the
invalid number from step 1, 127. (Of course, the contiguous set of numbers in
your actual list might be much longer.)

To find the encryption weakness, add together the smallest and largest number in
this contiguous range; in this example, these are 15 and 47, producing 62.
*/

use std::io;
use std::collections::VecDeque;

fn solve(window_length: usize, next: impl Iterator<Item=impl AsRef<str>>) -> i64 {
	let ns = next.map(|s| s.as_ref().parse::<i64>().unwrap()).collect::<Vec<_>>();
	let mut window = VecDeque::with_capacity(window_length);
	let bad = find_bad(&mut window, ns.iter().copied());

	for (i, a) in ns.iter().copied().enumerate() {
		let mut sum = a;
		let mut min = a;
		let mut max = a;
		for b in ns.iter().copied().skip(i + 1) {
			min = min.min(b);
			max = max.max(b);
			sum += b;
			if sum == bad {
				return min + max;
			}	
			if sum > bad {
				break;
			}
		}
	}

	panic!("bad input");
}

fn find_bad(window: &mut VecDeque<i64>, ns: impl Iterator<Item=i64>) -> i64 {
	for n in ns {
		if window.len() < window.capacity() {	
			window.push_back(n);
			continue;
		}

		let mut found = false;
		'out: for (i, a) in window.iter().enumerate().skip(1) {
			for b in window.iter().take(i) {
				if a + b == n {
					found = true;
					break 'out;
				}
			}
		}
		if !found {
			return n;
		}

		window.pop_front();
		window.push_back(n);
	}

	panic!("bad input");
}

fn main() {
	test();

	use io::BufRead;
	let stdin = io::stdin();
 
	let solution = solve(25, stdin.lock().lines().map(|s| s.unwrap()));

	println!("{}", solution);
}

fn test() {
	let solution = solve(5, [
		"35",
		"20",
		"15",
		"25",
		"47",
		"40",
		"62",
		"55",
		"65",
		"95",
		"102",
		"117",
		"150",
		"182",
		"127",
		"219",
		"299",
		"277",
		"309",
		"576",
	].iter());

	assert_eq!(62, solution);
}
