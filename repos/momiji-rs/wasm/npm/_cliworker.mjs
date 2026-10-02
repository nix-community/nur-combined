// The entry point of the CLI's worker threads. It marks the realm and then
// runs cli.mjs, which sees the mark and takes the worker path. Workers used to
// start from cli.mjs itself and tell themselves apart with
// `isMainThread`/`workerData`, which made every run load `node:worker_threads`
// (and the stream stack it brings) before its first compile, workers or not
// (#272).
globalThis[Symbol.for("sasso.cliWorker")] = true;
await import("./cli.mjs");
