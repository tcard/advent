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

use std::io;

fn solve(next: impl Iterator<Item=impl AsRef<str>>) -> i64 {
	let mut valid = 0;
	for line in next {
		let pass = parse_password(line.as_ref());
		let found = pass.password.matches(pass.policy.letter).count() as i64;
		if found >= pass.policy.min && found <= pass.policy.max {
			valid += 1;
		}
	}
	valid
}

struct Password<'a> {
	policy: PasswordPolicy<'a>,
	password: &'a str,
}

struct PasswordPolicy<'a> {
	letter: &'a str,
	min: i64,
	max: i64,
}

fn parse_password<'a>(s: &'a str) -> Password<'a> {
	let parts = s.split(" ").collect::<Vec<&str>>();
	let ( min_max, letter_colon, pass ) = {
		let s = parts.as_slice();
		(s[0], s[1], s[2])
	};
	let min_max_parts = min_max.split("-").collect::<Vec<&str>>();
	let ( min, max ) = {
		let s = min_max_parts.as_slice();
		(s[0], s[1])
	};
	let letter = &letter_colon[..letter_colon.len()-1];

	Password {
		policy: PasswordPolicy {
			letter: letter,
			min: min.parse().unwrap(),
			max: max.parse().unwrap(),
		},
		password: pass,
	}
}

fn main() {
	test();

	use io::BufRead;
	let stdin = io::stdin();
 
	let solution = solve(stdin.lock().lines().map(|s| s.unwrap()));

	println!("{}", solution);
}

fn test() {
	let solution = solve([
		String::from("1-3 a: abcde"),
		String::from("1-3 b: cdefg"),
		String::from("2-9 c: ccccccccc"),
	].iter());

	assert_eq!(2, solution);
}
