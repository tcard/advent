import sys

input = ''.join(l for l in sys.stdin).strip()

i = 4
while True:
    lastFour = input[i - 4:i]
    if len(set(lastFour)) == len(lastFour):
        print(i)
        break
    i += 1
