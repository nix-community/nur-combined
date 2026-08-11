import { PATCHED } from "@sindresorhus/is";

// Verify the patch was applied by checking for the PATCHED export
if ((PATCHED as boolean) !== true) {
  console.error("ERROR: Patch was not applied! Expected PATCHED to be true");
  process.exit(1);
}

console.log("SUCCESS: Scoped package patch was applied correctly!");
