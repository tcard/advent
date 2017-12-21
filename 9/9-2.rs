// --- Part Two ---

// Now, you're ready to remove the garbage.

// To prove you've removed it, you need to count all of the characters within
// the garbage. The leading and trailing < and > don't count, nor do any
// canceled characters or the ! doing the canceling.

//     <>, 0 characters.
//     <random characters>, 17 characters.
//     <<<<>, 3 characters.
//     <{!>}>, 2 characters.
//     <!!>, 0 characters.
//     <!!!>>, 0 characters.
//     <{o"i!a,<{i<a>, 10 characters.

// How many non-canceled characters are within the garbage in your puzzle input?

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
    garbage_length: i64,
}

#[derive(Copy, Clone)]
enum Parsed {
    Group(i64),
    Garbage(i64),
}

impl Parser {
    pub fn new() -> Self {
        Parser { level: 0, state: ParserState::Initial, garbage_length: 0 }
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
                    let parsed = Parsed::Garbage(self.garbage_length);
                    self.garbage_length = 0;
                    Ok(Some(parsed))
                },
                '!' => {
                    self.state = Cancelling;
                    Ok(None)
                },
                _ => {
                    self.garbage_length += 1;
                    Ok(None)
                },
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

fn garbage_length<I: Iterator<Item=char>>(input: I) -> Result<i64, String> {
    let mut parser = Parser::new();
    use Parsed::*;

    let mut total = 0;

    for parsed in input.map(|c| parser.parse(c)) {
        match parsed {
            Ok(Some(Garbage(length))) => { total += length; },
            Err(err) => { return Err(err); },
            _ => (),
        }
    }

    Ok(total)
}

fn run_tests() {
    for &(input, expected) in [
        ("<>", 0),
        ("<random characters>", 17),
        ("<<<<>", 3),
        ("<{!>}>", 2),
        ("<!!>", 0),
        ("<!!!>>", 0),
        ("<{o\"i!a,<{i<a>", 10),
    ].iter() {
        assert_eq!(expected, garbage_length(input.chars()).unwrap());
    }
}

fn process_input() {
    use std::io::Read;
    println!("{}", garbage_length(std::io::stdin()
        .chars()
        .map(|c| c.unwrap())
        .filter(|c| *c != '\n')
    ).unwrap());
}

fn main() {
    run_tests();
    process_input();
}
