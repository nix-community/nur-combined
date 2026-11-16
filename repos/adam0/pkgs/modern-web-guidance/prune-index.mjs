// Drops search entries whose guide file is missing, keeping the vector rows aligned with the chunk list.
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { gunzipSync, gzipSync } from "node:zlib";

const root = process.argv[2];
const gen = join(root, "gen");
const hasGuide = ({ id, category }) => existsSync(join(root, "guides", category, `${id}.md`));

const guides = JSON.parse(readFileSync(join(gen, "guides.json"), "utf8"));
const kept = guides.filter(hasGuide);
const keptIds = new Set(kept.map(({ id }) => id));
for (const { id } of guides) if (!keptIds.has(id)) console.log(`pruned ${id}`);
if (kept.length === 0) throw new Error("no guides left after pruning");
writeFileSync(join(gen, "guides.json"), JSON.stringify(kept));

const chunks = JSON.parse(gunzipSync(readFileSync(join(gen, "guide-chunks.json.gz"))).toString("utf8"));
const vectors = readFileSync(join(gen, "guide-chunks.i8"));
const scales = readFileSync(join(gen, "guide-chunks.scale.f32"));
const width = vectors.byteLength / chunks.length;
if (!Number.isInteger(width) || scales.byteLength !== chunks.length * 4) {
  throw new Error("chunk vectors are not aligned with guide-chunks.json.gz");
}

const rows = chunks.flatMap((chunk, row) => (keptIds.has(chunk.id) ? [row] : []));
writeFileSync(join(gen, "guide-chunks.json.gz"), gzipSync(JSON.stringify(rows.map((row) => chunks[row]))));
writeFileSync(join(gen, "guide-chunks.i8"), Buffer.concat(rows.map((row) => vectors.subarray(row * width, (row + 1) * width))));
writeFileSync(join(gen, "guide-chunks.scale.f32"), Buffer.concat(rows.map((row) => scales.subarray(row * 4, row * 4 + 4))));
console.log(`kept ${kept.length}/${guides.length} guides and ${rows.length}/${chunks.length} chunks`);
