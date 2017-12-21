// --- Day 9: Stream Processing ---

// A large stream blocks your path. According to the locals, it's not safe to
// cross the stream at the moment because it's full of garbage. You look down at
// the stream; rather than water, you discover that it's a stream of characters.

// You sit for a while and record part of the stream (your puzzle input). The
// characters represent groups - sequences that begin with { and end with }.
// Within a group, there are zero or more other things, separated by commas:
// either another group or garbage. Since groups can contain other groups, a }
// only closes the most-recently-opened unclosed group - that is, they are
// nestable. Your puzzle input represents a single, large group which itself
// contains many smaller ones.

// Sometimes, instead of a group, you will find garbage. Garbage begins with <
// and ends with >. Between those angle brackets, almost any character can
// appear, including { and }. Within garbage, < has no special meaning.

// In a futile attempt to clean up the garbage, some program has canceled some
// of the characters within it using !: inside garbage, any character that comes
// after ! should be ignored, including <, >, and even another !.

// You don't see any characters that deviate from these rules. Outside garbage,
// you only find well-formed groups, and garbage always terminates according to
// the rules above.

// Here are some self-contained pieces of garbage:

//     <>, empty garbage.
//     <random characters>, garbage containing random characters.
//     <<<<>, because the extra < are ignored.
//     <{!>}>, because the first > is canceled.
//     <!!>, because the second ! is canceled, allowing the > to terminate the garbage.
//     <!!!>>, because the second ! and the first > are canceled.
//     <{o"i!a,<{i<a>, which ends at the first >.

// Here are some examples of whole streams and the number of groups they
// contain:

//     {}, 1 group.
//     {{{}}}, 3 groups.
//     {{},{}}, also 3 groups.
//     {{{},{},{{}}}}, 6 groups.
//     {<{},{},{{}}>}, 1 group (which itself contains garbage).
//     {<a>,<a>,<a>,<a>}, 1 group.
//     {{<a>},{<a>},{<a>},{<a>}}, 5 groups.
//     {{<!>},{<!>},{<!>},{<a>}}, 2 groups (since all but the last > are canceled).

// Your goal is to find the total score for all groups in your input. Each group
// is assigned a score which is one more than the score of the group that
// immediately contains it. (The outermost group gets a score of 1.)

//     {}, score of 1.
//     {{{}}}, score of 1 + 2 + 3 = 6.
//     {{},{}}, score of 1 + 2 + 2 = 5.
//     {{{},{},{{}}}}, score of 1 + 2 + 3 + 3 + 3 + 4 = 16.
//     {<a>,<a>,<a>,<a>}, score of 1.
//     {{<ab>},{<ab>},{<ab>},{<ab>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
//     {{<!!>},{<!!>},{<!!>},{<!!>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
//     {{<a!>},{<a!>},{<a!>},{<ab>}}, score of 1 + 2 = 3.

// What is the total score for all groups in your input?

#![feature(io)]

#[derive(Copy, Clone)]
enum ParserState {
    Initial,
    Closed,
    InGarbage,
    Cancelling, 
}

struct Parser {
    level: i64,
    state: ParserState,
}

#[derive(Copy, Clone)]
enum Parsed {
    Group(i64),
    Garbage,
}

impl Parser {
    pub fn new() -> Self {
        Parser { level: 0, state: ParserState::Initial }
    }

    pub fn parse(&mut self, input: char) -> Result<Option<Parsed>, String> {
        use ParserState::*;

        let state = self.state;
        match state {
            Initial => match input {
                '{' => {
                    self.level += 1;
                    Ok(None)
                },
                '}' => self.close_group().map(|x| Some(x)),
                '<' => {
                    self.state = InGarbage;
                    Ok(None)
                },
                bad => Err(format!("unexpected character: {}", bad)),
            },

            Closed => match input {
                ',' => {
                    self.state = Initial;
                    Ok(None)
                },
                '}' => self.close_group().map(|x| Some(x)),
                bad => Err(format!("unexpected character: {}", bad)),
            }

            InGarbage => match input {
                '>' => {
                    self.state = Closed;
                    Ok(Some(Parsed::Garbage))
                },
                '!' => {
                    self.state = Cancelling;
                    Ok(None)
                },
                _ => Ok(None),
            },

            Cancelling => {
                self.state = InGarbage;
                Ok(None)
            },
        }
    }

    fn close_group(&mut self) -> Result<Parsed, String> {
        if self.level <= 0 {
            Err("group closed when at root level".into())
        } else {
            let parsed = Parsed::Group(self.level);
            self.level -= 1;
            self.state = ParserState::Closed;
            Ok(parsed)
        }
    }
}

fn score<I: Iterator<Item=char>>(input: I) -> Result<i64, String> {
    let mut parser = Parser::new();
    use Parsed::*;

    let mut score = 0;

    for parsed in input.map(|c| parser.parse(c)) {
        match parsed {
            Ok(Some(Group(level))) => { score += level; },
            Err(err) => { return Err(err); },
            _ => (),
        }
    }

    Ok(score)
}

fn run_tests() {
    for &(input, expected) in [
        ("{}", 1),
        ("{{{}}}", 6),
        ("{{},{}}", 5),
        ("{{{},{},{{}}}}", 16),
        ("{<a>,<a>,<a>,<a>}", 1),
        ("{{<ab>},{<ab>},{<ab>},{<ab>}}", 9),
        ("{{<!!>},{<!!>},{<!!>},{<!!>}}", 9),
        ("{{<a!>},{<a!>},{<a!>},{<ab>}}", 3),
    ].iter() {
        assert_eq!(expected, score(input.chars()).unwrap());
    }
}

fn process_input() {
    use std::io::Read;
    println!("{}", score(std::io::stdin()
        .chars()
        .map(|c| c.unwrap())
        .filter(|c| *c != '\n')
    ).unwrap());
}

fn main() {
    run_tests();
    process_input();
}
