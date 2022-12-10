fn main() {
    let mut ops = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0)
        .map(|line| Op::parse(&line));

    let mut register = 1;

    let mut op = ops.next().unwrap();
    let mut execute_at_cycle = op.cycles();

    for after_cycle in 0..=240 {
        if after_cycle == execute_at_cycle {
            op.execute(&mut register);
            op = ops.next().unwrap_or(Op::Noop);
            execute_at_cycle += op.cycles();
        }

        let pixel_drawn = after_cycle % 40;
        let lit = pixel_drawn >= register - 1 && pixel_drawn <= register + 1;

        print!("{}", if lit { '#' } else { ' ' });
        if pixel_drawn == 39 {
            println!();
        }
    }
}

#[derive(Debug)]
enum Op {
    Addx(i64),
    Noop,
}

impl Op {
    fn parse(src: &str) -> Self {
        let parts: Vec<_> = src.split(" ").collect();
        match parts.as_slice() {
            &["addx", n] => Op::Addx(n.parse().unwrap()),
            &["noop"] => Op::Noop,
            _ => panic!("malformed line {}", src),
        }
    }

    fn execute(&self, register: &mut i64) {
        match self {
            Op::Addx(n) => *register += n,
            Op::Noop => {}
        }
    }

    fn cycles(&self) -> i64 {
        match self {
            Op::Addx(_) => 2,
            Op::Noop => 1,
        }
    }
}
