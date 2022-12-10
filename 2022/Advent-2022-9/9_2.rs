use std::collections::HashSet;

fn main() {
    let moves = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0)
        .map(|line| Move::parse(&line));

    let mut rope = [(0, 0); 10];

    let mut unique_tail_positions: HashSet<(i64, i64)> = HashSet::new();

    for Move { direction, steps } in moves {
        for _ in 0..steps {
            rope[0] = direction.go(rope[0]);

            for i in 1..10 {
                let pos = rope[i];
                let lead = rope[i - 1];

                if (pos.0 - lead.0).abs() <= 1 && (pos.1 - lead.1).abs() <= 1 {
                    continue;
                }

                rope[i] = if pos.0 == lead.0 {
                    if pos.1 > lead.1 {
                        (pos.0, pos.1 - 1)
                    } else {
                        (pos.0, pos.1 + 1)
                    }
                } else if pos.1 == lead.1 {
                    if pos.0 > lead.0 {
                        (pos.0 - 1, pos.1)
                    } else {
                        (pos.0 + 1, pos.1)
                    }
                } else if pos.0 > lead.0 {
                    if pos.1 > lead.1 {
                        (pos.0 - 1, pos.1 - 1)
                    } else {
                        (pos.0 - 1, pos.1 + 1)
                    }
                } else if pos.0 < lead.0 {
                    if pos.1 > lead.1 {
                        (pos.0 + 1, pos.1 - 1)
                    } else {
                        (pos.0 + 1, pos.1 + 1)
                    }
                } else {
                    panic!("unexpected");
                }
            }

            unique_tail_positions.insert(rope[9]);
        }
    }

    println!("{}", unique_tail_positions.len());
}

struct Move {
    direction: Direction,
    steps: u64,
}

impl Move {
    fn parse(src: &str) -> Self {
        let parts: Vec<_> = src.split(" ").collect();
        match parts.as_slice() {
            &[direction, steps] => Move {
                direction: match direction.chars().nth(0).unwrap() {
                    'U' => Direction::Up,
                    'D' => Direction::Down,
                    'L' => Direction::Left,
                    'R' => Direction::Right,
                    _ => panic!("unexpected direction {}", direction),
                },
                steps: steps.parse().unwrap(),
            },
            _ => panic!("malformed line {}", src),
        }
    }
}

enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl Direction {
    fn go(&self, pos: (i64, i64)) -> (i64, i64) {
        let vector = match self {
            Direction::Up => (0, -1),
            Direction::Down => (0, 1),
            Direction::Left => (-1, 0),
            Direction::Right => (1, 0),
        };
        (pos.0 + vector.0, pos.1 + vector.1)
    }
}
