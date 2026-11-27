// Run from the node_modules directory that contains onnxruntime-node.
const ort = require(`${process.cwd()}/onnxruntime-node`);

// An ONNX model with a single Identity node from float[2] `x` to `y`.
const model = Buffer.from(
  "CAg6NwoQCgF4EgF5IghJZGVudGl0eRIBZ1oPCgF4EgoKCAgBEgQKAggCYg8KAXkSCgoICAESBAoCCAJCBAoAEA0=",
  "base64",
);

(async () => {
  const session = await ort.InferenceSession.create(model);
  const { y } = await session.run({ x: new ort.Tensor("float32", [1, 2], [2]) });
  if (y.data[0] !== 1 || y.data[1] !== 2) {
    throw new Error(`unexpected Identity output: ${Array.from(y.data)}`);
  }
  console.log("onnxruntime-node", ort.env.versions.node, ort.listSupportedBackends());
})();
