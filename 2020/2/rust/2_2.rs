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

use std::io;

fn solve(next: impl Iterator<Item=impl AsRef<str>>) -> i64 {
	let mut valid = 0;
	for line in next {
		let pass = parse_password(line.as_ref());
		let found = pass.policy.valid_positions.iter().filter(|i| {
			&pass.password[*i-1 .. **i] == pass.policy.letter
		}).count();
		if found == 1 {
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
	valid_positions: Vec<usize>,
}

fn parse_password<'a>(s: &'a str) -> Password<'a> {
	let parts = s.split(" ").collect::<Vec<&str>>();
	let ( valid, letter_colon, pass ) = {
		let s = parts.as_slice();
		(s[0], s[1], s[2])
	};
	let valid_parts = valid.split("-").collect::<Vec<&str>>();
	let valid_positions = valid_parts
		.as_slice().iter()
		.map(|x| x.parse().unwrap())
		.collect();
	let letter = &letter_colon[..letter_colon.len()-1];

	Password {
		policy: PasswordPolicy {
			letter: letter,
			valid_positions: valid_positions,
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

	assert_eq!(1, solution);
}
