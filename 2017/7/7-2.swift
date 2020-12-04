// --- Part Two ---

// The programs explain the situation: they can't get down. Rather, they could
// get down, if they weren't expending all of their energy trying to keep the
// tower balanced. Apparently, one program has the wrong weight, and until it's
// fixed, they're stuck here.

// For any program holding a disc, each program standing on that disc forms a
// sub-tower. Each of those sub-towers are supposed to be the same weight, or
// the disc itself isn't balanced. The weight of a tower is the sum of the
// weights of the programs in that tower.

// In the example above, this means that for ugml's disc to be balanced, gyxo,
// ebii, and jptl must all have the same weight, and they do: 61.

// However, for tknk to be balanced, each of the programs standing on its disc
// and all programs above it must each match. This means that the following sums
// must all be the same:

// ugml + (gyxo + ebii + jptl) = 68 + (61 + 61 + 61) = 251
// padx + (pbga + havc + qoyq) = 45 + (66 + 66 + 66) = 243
// fwft + (ktlj + cntj + xhth) = 72 + (57 + 57 + 57) = 243

// As you can see, tknk's disc is unbalanced: ugml's stack is heavier than the
// other two. Even though the nodes above ugml are balanced, ugml itself is too
// heavy: it needs to be 8 units lighter for its stack to weigh 243 and keep the
// towers balanced. If this change were made, its weight would be 60.

// Given that exactly one program is the wrong weight, what would its weight
// need to be to balance the entire tower?

import Foundation

struct Program {
    var name: String
    var weight: Int
    var holding: [String]
}

extension String: Error {}

func bottomProgram(_ programs: [Program]) throws -> Program {
    var held: Set<String> = []
    var candidates: [String: Program] = [:]

    for program in programs {
        for h in program.holding {
            held.insert(h)
            candidates.removeValue(forKey: h)
        }

        if !held.contains(program.name) {
            candidates[program.name] = program
        }
    }

    if candidates.count != 1 {
        throw "malformed program tower: expected 1 bottom program, got \(candidates.count): \(Array(candidates.values))"
    }

    return candidates.first!.value
}

struct ProgramTower {
    private var programs: [String: Program] = [:]

    var bottom: Program

    init(with programs: [Program]) throws {
        for program in programs {
            self.programs[program.name] = program
        }

        self.bottom = try bottomProgram(programs)
    }

    func getHeld(by program: Program) -> [Program] {
        return program.holding.map { programs[$0]! }
    }
}

func unbalance(of programs: [Program]) throws -> Int? {
    let tower = try ProgramTower(with: programs)

    enum towerUnbalance {
        case ok(Int)
        case unbalanced(Int)
    }

    func findUnbalance(from program: Program) -> towerUnbalance {
        var weightHeld = 0
        var prev: (Program, Int)?

        for held in tower.getHeld(by: program) {
            switch findUnbalance(from: held) {
            case .unbalanced(let should):
                return .unbalanced(should)
            case .ok(let weight):
                if let (prevHeld, prevWeight) = prev {
                    if prevWeight != weight {
                        let heaviest = prevWeight > weight ? prevHeld : held
                        return .unbalanced(heaviest.weight - abs(weight - prevWeight))
                    }
                }

                prev = (held, weight)
                weightHeld += weight
            }
        }

        return .ok(weightHeld + program.weight)
    }

    switch findUnbalance(from: tower.bottom) {
    case .unbalanced(let should):
        return should
    default:
        return nil
    }
}

func runTests() throws {
    for (input, expected) in [
        ([
            ("pbga", 66, []),
            ("xhth", 57, []),
            ("ebii", 61, []),
            ("havc", 66, []),
            ("ktlj", 57, []),
            ("fwft", 72, ["ktlj", "cntj", "xhth"]),
            ("qoyq", 66, []),
            ("padx", 45, ["pbga", "havc", "qoyq"]),
            ("tknk", 41, ["ugml", "padx", "fwft"]),
            ("jptl", 61, []),
            ("ugml", 68, ["gyxo", "ebii", "jptl"]),
            ("gyxo", 61, []),
            ("cntj", 57, []),
        ], 60)
    ] {
        let got = try unbalance(of: input.map({ input in
            let (name, weight, holding) = input
            return Program(name: name, weight: weight, holding: holding)
        }))
        if expected != got {
            throw "expected \(expected), got \(String(describing: got))"
        }
    }
}

func processInput() throws {
    let regexp = try! NSRegularExpression(pattern: "^([a-z]+) \\(([0-9]+)\\)( -> ([a-z]+(, [a-z]+)*))?")

    var programs: [Program] = []

    while let line = readLine(strippingNewline: true) {
        guard let match = regexp.matches(in: line, range: NSMakeRange(0, line.utf16.count)).first else {
            continue
        }

        func getRange(_ i: Int) -> String? {
            let range = match.rangeAt(i)
            if range.length == 0 {
                return nil
            }
            let start = String.UTF16Index(range.location)
            let end = String.UTF16Index(range.location + range.length)
            return String(line.utf16[start ..< end])
        }
        
        programs.append(Program(
            name: getRange(1)!,
            weight: Int(getRange(2)!)!,
            holding: getRange(4).map { ($0 as NSString).components(separatedBy: ", ") } ?? []
        ))
    }

    print("\(try unbalance(of: programs)!)")
}

try runTests()
try processInput()
