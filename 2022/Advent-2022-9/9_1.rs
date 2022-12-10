use std::collections::HashSet;

fn main() {
    let moves = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0)
        .map(|line| Move::parse(&line));

    let mut head_pos = (0, 0);
    let mut tail_pos = (0, 0);

    let mut unique_tail_positions: HashSet<(i64, i64)> = HashSet::new();

    for Move { direction, steps } in moves {
        for _ in 0..steps {
            head_pos = direction.go(head_pos);

            tail_pos = if head_pos.1 - tail_pos.1 > 1 {
                (head_pos.0, head_pos.1 - 1)
            } else if head_pos.1 - tail_pos.1 < -1 {
                (head_pos.0, head_pos.1 + 1)
            } else if head_pos.0 - tail_pos.0 > 1 {
                (head_pos.0 - 1, head_pos.1)
            } else if head_pos.0 - tail_pos.0 < -1 {
                (head_pos.0 + 1, head_pos.1)
            } else {
                tail_pos
            };

            unique_tail_positions.insert(tail_pos);
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
