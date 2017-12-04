# --- Day 4: High-Entropy Passphrases ---

# A new system policy has been put in place that requires all accounts to use a
# passphrase instead of simply a password. A passphrase consists of a series of
# words (lowercase letters) separated by spaces.

# To ensure security, a valid passphrase must contain no duplicate words.

# For example:

# aa bb cc dd ee is valid.

# aa bb cc dd aa is not valid - the word aa appears more than once.

# aa bb cc dd aaa is valid - aa and aaa count as different words.

# The system's full passphrase list is available as your puzzle input. How many
# passphrases are valid?

import sets
import strutils

proc isValid(passphrase: openArray[string]): bool =
  var seen = sets.initSet[string]()

  for word in passphrase:
    if word in seen:
      return false
    seen.incl(word)

  return true

for testCase in [
  (@["aa", "bb", "cc", "dd", "ee"], true),
  (@["aa", "bb", "cc", "dd", "aa"], false),
  (@["aa", "bb", "cc", "dd", "aaa"], true),
]:
  var (input, expected) = testCase
  assert(expected == isValid(input))

var valid = 0

try:
  while true:
    var line = readLine(stdin)
    var passphrase = line.splitWhitespace
    if isValid(passphrase):
      valid += 1
except EOFError:
  discard

echo valid
