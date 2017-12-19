// --- Day 7: Recursive Circus ---

// Wandering further through the circuits of the computer, you come upon a tower
// of programs that have gotten themselves into a bit of trouble. A recursive
// algorithm has gotten out of hand, and now they're balanced precariously in a
// large tower.

// One program at the bottom supports the entire tower. It's holding a large
// disc, and on the disc are balanced several more sub-towers. At the bottom of
// these sub-towers, standing on the bottom disc, are other programs, each
// holding their own disc, and so on. At the very tops of these sub-sub-
// sub-...-towers, many programs stand simply keeping the disc below them
// balanced but with no disc of their own.

// You offer to help, but first you need to understand the structure of these
// towers. You ask each program to yell out their name, their weight, and (if
// they're holding a disc) the names of the programs immediately above them
// balancing on that disc. You write this information down (your puzzle input).
// Unfortunately, in their panic, they don't do this in an orderly fashion; by
// the time you're done, you're not sure which program gave which information.

// For example, if your list is the following:

// pbga (66)
// xhth (57)
// ebii (61)
// havc (66)
// ktlj (57)
// fwft (72) -> ktlj, cntj, xhth
// qoyq (66)
// padx (45) -> pbga, havc, qoyq
// tknk (41) -> ugml, padx, fwft
// jptl (61)
// ugml (68) -> gyxo, ebii, jptl
// gyxo (61)
// cntj (57)

// ...then you would be able to recreate the structure of the towers that looks
// ...like this:

//                 gyxo
//               /     
//          ugml - ebii
//        /      \     
//       |         jptl
//       |        
//       |         pbga
//      /        /
// tknk --- padx - havc
//      \        \
//       |         qoyq
//       |             
//       |         ktlj
//        \      /     
//          fwft - cntj
//               \     
//                 xhth

// In this example, tknk is at the bottom of the tower (the bottom program), and
// is holding up ugml, padx, and fwft. Those programs are, in turn, holding up
// other programs; in this example, none of those programs are holding up any
// other programs, and are all the tops of their own towers. (The actual tower
// balancing in front of you is much larger.)

// Before you're ready to help them, you need to make sure your information is
// correct. What is the name of the bottom program?

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
        ], "tknk")
    ] {
        let got = try bottomProgram(input.map({ input in
            let (name, weight, holding) = input
            return Program(name: name, weight: weight, holding: holding)
        })).name
        if expected != got {
            throw "expected \(expected), got \(got)"
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

    print("\(try bottomProgram(programs).name)")
}

try runTests()
try processInput()
