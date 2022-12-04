const fs = require("fs");

const input = fs.readFileSync("/dev/stdin").toString();

const rucksacks = input.split("\n").map((line) => new Set(line));

const groups = [];
for (const [i, sack] of rucksacks.entries()) {
  if (i % 3 === 0) {
    groups.push([]);
  }
  groups[groups.length - 1].push(sack);
}

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

groupsLoop: for (const [a, b, c] of groups) {
  for (const itemType of a) {
    if (b.has(itemType) && c.has(itemType)) {
      sum += priority(itemType);
      continue groupsLoop;
    }
  }
}

console.log(sum);
