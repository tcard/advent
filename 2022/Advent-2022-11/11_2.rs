fn main() {
    let mut lines = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0);

    let mut monkeys = parse_monkeys(&mut lines);

    let mut lcm = 1;
    for monkey in &monkeys {
        lcm *= monkey.test.divisible_by
    }

    let mut inspections: Vec<u64> = vec![0; monkeys.len()];

    for _ in 0..10_000 {
        for monkey_id in 0..monkeys.len() {
            let mut throws: Vec<(usize, u128)> = vec![];
            {
                let monkey = &mut monkeys[monkey_id];
                for item in &monkey.items {
                    inspections[monkey_id] += 1;
                    let new_item = monkey.op.eval(*item);
                    let reduced_item = new_item % lcm;
                    throws.push((
                        if reduced_item % monkey.test.divisible_by == 0 {
                            monkey.test.if_true_throw_to
                        } else {
                            monkey.test.if_false_throw_to
                        },
                        reduced_item,
                    ));
                }
                monkey.items.clear();
            }

            for (to, item) in throws {
                monkeys[to].items.push(item);
            }
        }
    }

    inspections.sort();
    println!(
        "{}",
        inspections[inspections.len() - 1] * inspections[inspections.len() - 2]
    );
}

fn parse_monkeys(lines: &mut impl Iterator<Item = String>) -> Vec<Monkey> {
    let mut monkeys = vec![];

    while let Some(_) = lines.next() {
        let mut line = lines.next().unwrap();
        let starting_items: Vec<u128> = line
            .split_off("  Starting items: ".len())
            .split(", ")
            .map(|v| v.parse().unwrap())
            .collect();

        line = lines.next().unwrap();
        let op = BinOp::parse(&line.split_off("  Operation: new = ".len()));

        line = lines.next().unwrap();
        let divisible_by: u128 = line
            .split_off("  Test: divisible by ".len())
            .parse()
            .unwrap();

        line = lines.next().unwrap();
        let if_true_throw_to: usize = line
            .split_off("    If true: throw to monkey ".len())
            .parse()
            .unwrap();

        line = lines.next().unwrap();
        let if_false_throw_to: usize = line
            .split_off("    If false: throw to monkey ".len())
            .parse()
            .unwrap();

        let test = Test {
            divisible_by,
            if_true_throw_to,
            if_false_throw_to,
        };

        monkeys.push(Monkey {
            items: starting_items,
            op,
            test,
        });
    }

    monkeys
}

#[derive(Debug)]
struct Monkey {
    items: Vec<u128>,
    op: BinOp,
    test: Test,
}

#[derive(Debug)]
struct BinOp {
    a: Operand,
    b: Operand,
    op: Op,
}

impl BinOp {
    fn parse(src: &str) -> Self {
        let parts: Vec<_> = src.split(" ").collect();
        match parts.as_slice() {
            &[a, op, b] => BinOp {
                a: Operand::parse(a),
                b: Operand::parse(b),
                op: Op::parse(op),
            },
            _ => panic!("malformed BinOp"),
        }
    }

    fn eval(&self, old: u128) -> u128 {
        let a = self.a.eval(old);
        let b = self.b.eval(old);
        match &self.op {
            Op::Add => a + b,
            Op::Mul => a * b,
        }
    }
}

#[derive(Debug)]
enum Operand {
    Literal(u128),
    Old,
}

impl Operand {
    fn parse(src: &str) -> Self {
        match src {
            "old" => Operand::Old,
            n => Operand::Literal(n.parse().unwrap()),
        }
    }

    fn eval(&self, old: u128) -> u128 {
        match self {
            Operand::Old => old,
            Operand::Literal(n) => *n,
        }
    }
}

#[derive(Debug)]
enum Op {
    Add,
    Mul,
}

impl Op {
    fn parse(src: &str) -> Self {
        match src {
            "+" => Op::Add,
            "*" => Op::Mul,
            _ => panic!("malformed Op"),
        }
    }
}

#[derive(Debug)]
struct Test {
    divisible_by: u128,
    if_true_throw_to: usize,
    if_false_throw_to: usize,
}
