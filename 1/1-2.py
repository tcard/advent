#!/usr/bin/env python

# --- Part Two ---

# You notice a progress bar that jumps to 50% completion. Apparently, the door
# isn't yet satisfied, but it did emit a star as encouragement. The instructions
# change:

# Now, instead of considering the next digit, it wants you to consider the digit
# halfway around the circular list. That is, if your list contains 10 items,
# only include a digit in your sum if the digit 10/2 = 5 steps forward matches
# it. Fortunately, your list has an even number of elements.

# For example:

# 1212 produces 6: the list contains 4 items, and all four digits match the
# digit 2 items ahead. 1221 produces 0, because every comparison is between a 1
# and a 2. 123425 produces 4, because both 2s match each other, but no other
# digit has a match. 123123 produces 12. 12131415 produces 4. What is the
# solution to your new captcha?


def reverse_captcha(digits):
    digits = list(digits)

    def halfway_around(i):
        j = i + len(digits) / 2
        if j >= len(digits):
            j %= len(digits)
        return digits[j]

    sum = 0

    for i, d in enumerate(digits):
        if d == halfway_around(i):
            sum += d

    return sum


for number, expected in [
    (1212, 6),
    (1221, 0),
    (123425, 4),
    (123123, 12),
]:
    digits = (int(d) for d in str(number))
    assert(reverse_captcha(digits) == expected)


if __name__ == '__main__':
    def digits_from_file(file):
        while True:
            c = file.read(1)
            if len(c) == 0:
                return
            try:
                yield int(c)
            except ValueError:
                pass

    import sys

    digits = digits_from_file(sys.stdin)

    print reverse_captcha(digits)
