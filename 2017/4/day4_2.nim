# --- Part Two ---

# For added security, yet another system policy has been put in place. Now, a
# valid passphrase must contain no two words that are anagrams of each other -
# that is, a passphrase is invalid if any word's letters can be rearranged to form
# any other word in the passphrase.

# For example:

# abcde fghij is a valid passphrase.

# abcde xyz ecdab is not valid - the letters from the third word can be rearranged
# to form the first word.

# a ab abc abd abf abj is a valid passphrase, because all letters need to be used
# when forming another word.

# iiii oiii ooii oooi oooo is valid.

# oiii ioii iioi iiio is not valid - any of these words can be rearranged to form
# any other word.

# Under this new system policy, how many passphrases are valid?

import sets
import strutils
import unicode
import algorithm

proc isValid(passphrase: openArray[string]): bool =
  var seen = sets.initSet[string]()

  for word in passphrase:
    var runes = word.toRunes

    sort(runes) do (a, b: Rune) -> int:
      if a <=% b:
        return -1
      else:
        return 1

    var sortedWord = runes.`$`
    if sortedWord in seen:
      return false
    seen.incl(sortedWord)

  return true

for testCase in [
  (@["abcde", "fghij"], true),
  (@["abcde", "xyz", "ecdab"], false),
  (@["a", "ab", "abc", "abd", "abf", "abj"], true),
  (@["iiii", "oiii", "ooii", "oooi", "oooo"], true),
  (@["oiii", "ioii", "iioi", "iiio"], false)
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
