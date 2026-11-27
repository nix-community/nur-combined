// Run from the package root with `node --input-type=module < this file`, so bare
// specifiers resolve through the package's node_modules as the bundle's do.
import { createRequire } from "node:module";
import { dirname } from "node:path";
import { pathToFileURL } from "node:url";
import * as ort from "onnxruntime-web";
// Transformers.js imports this entry when its WASM fallback loads.
import "onnxruntime-web/webgpu";

const entry = createRequire(`${process.cwd()}/`).resolve("onnxruntime-web");
ort.env.wasm.numThreads = 1;
ort.env.wasm.wasmPaths = `${pathToFileURL(dirname(entry)).href}/`;

// An ONNX model with a single Identity node from float[2] `x` to `y`.
const model = Buffer.from(
  "CAg6NwoQCgF4EgF5IghJZGVudGl0eRIBZ1oPCgF4EgoKCAgBEgQKAggCYg8KAXkSCgoICAESBAoCCAJCBAoAEA0=",
  "base64",
);
const session = await ort.InferenceSession.create(model);
const { y } = await session.run({ x: new ort.Tensor("float32", [1, 2], [2]) });
if (y.data[0] !== 1 || y.data[1] !== 2) {
  throw new Error(`unexpected Identity output: ${Array.from(y.data)}`);
}
