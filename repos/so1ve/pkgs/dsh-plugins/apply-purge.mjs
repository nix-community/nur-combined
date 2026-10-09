import assert from "node:assert/strict";
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const [source, installation] = process.argv.slice(2);
const core = await import(pathToFileURL(join(source, "lib/core.js")));

mkdirSync(process.env.DSH_HOME, { recursive: true });
const report = await core.applyPatches(
  join(installation, "node_modules/@deepseek-ai"),
);
const summary = core.summarizeApplyReport(report);

assert.equal(summary.failed.length, 0, JSON.stringify(summary.failed, null, 2));
assert(
  summary.applied + summary.already > 0,
  "Purge did not match any host files",
);

writeFileSync(
  join(installation, "purge-patches.json"),
  JSON.stringify(report, null, 2) + "\n",
);
console.log(
  `Purge: ${summary.applied} patches applied, ${summary.already} already present`,
);
