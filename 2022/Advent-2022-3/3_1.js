const fs = require("fs");

const input = fs.readFileSync("/dev/stdin").toString();

const rucksacks = input
  .split("\n")
  .map((line) => [line.slice(0, line.length / 2), line.slice(line.length / 2)]);

function priority(itemType) {
  const code = itemType.charCodeAt(0);
  return (
    1 +
    (code >= "a".charCodeAt(0)
      ? code - "a".charCodeAt(0)
      : code - "A".charCodeAt(0) + 26)
  );
}

let sum = 0;

rucksacksLoop: for (const [pocketA, pocketB] of rucksacks) {
  const aSet = new Set(pocketA);
  for (const itemType of pocketB) {
    if (aSet.has(itemType)) {
      sum += priority(itemType);
      continue rucksacksLoop;
    }
  }
}

console.log(sum);
