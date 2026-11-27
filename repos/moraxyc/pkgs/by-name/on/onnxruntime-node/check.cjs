const fs = require("node:fs");
const path = require("node:path");

// Run from the node_modules directory that contains onnxruntime-node.
const pkgDir = path.join(process.cwd(), "onnxruntime-node");
const ort = require(pkgDir);

// An ONNX model with a single Identity node from float[2] `x` to `y`.
const model = Buffer.from(
  "CAg6NwoQCgF4EgF5IghJZGVudGl0eRIBZ1oPCgF4EgoKCAgBEgQKAggCYg8KAXkSCgoICAESBAoCCAJCBAoAEA0=",
  "base64",
);

(async () => {
  const bindingDir = path.join(pkgDir, "bin", "napi-v6", process.platform, process.arch);
  const entries = fs.readdirSync(bindingDir);
  for (const entry of entries) {
    fs.statSync(path.join(bindingDir, entry));
  }

  const backends = ort.listSupportedBackends();
  if (process.platform === "linux" && backends.some((b) => b.name === "cuda")) {
    for (const required of ["libonnxruntime_providers_shared.so", "libonnxruntime_providers_cuda.so"]) {
      if (!entries.includes(required)) {
        throw new Error(`missing CUDA provider library in ${bindingDir}: ${required}`);
      }
    }
  }

  const session = await ort.InferenceSession.create(model);
  const { y } = await session.run({ x: new ort.Tensor("float32", [1, 2], [2]) });
  if (y.data[0] !== 1 || y.data[1] !== 2) {
    throw new Error(`unexpected Identity output: ${Array.from(y.data)}`);
  }
  console.log("onnxruntime-node", ort.env.versions.node, backends);
})();
