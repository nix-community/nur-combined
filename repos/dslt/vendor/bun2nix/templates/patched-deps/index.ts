import isNumber from "is-number";

// Verify the patch was applied by checking for the PATCHED export
const patched = (isNumber as any).PATCHED;

if (patched !== true) {
  console.error(
    "ERROR: Patch was not applied! Expected isNumber.PATCHED to be true",
  );
  process.exit(1);
}

console.log("SUCCESS: Patch was applied correctly!");
console.log("isNumber(42) =", isNumber(42));
