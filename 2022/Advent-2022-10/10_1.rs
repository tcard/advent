fn main() {
    let ops = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0)
        .map(|line| Op::parse(&line));

    let mut register = 1;
    let mut cycles = 0;
    let mut result = 0;

    for op in ops {
        for n in [20, 60, 100, 140, 180, 220] {
            if cycles > n {
                continue;
            }
            if n > cycles && n <= cycles + op.cycles() {
                result += n * register;
                continue;
            }
        }
        op.execute(&mut register);
        cycles += op.cycles();
    }

    println!("{}", result);
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
