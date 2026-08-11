import { isEven, isOdd } from "@workspace/lib";

const RESET_COLOUR = "\x1b[0m";

console.log(`${Bun.color("blue", "ansi")}Testing workspace dependency:`);
console.log(`${RESET_COLOUR}Is 3 odd? ${isOdd(3)}`);
console.log(`${RESET_COLOUR}Is 4 even? ${isEven(4)}`);
console.log(`${Bun.color("green", "ansi")}Success!`);
