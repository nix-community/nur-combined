// Repo-internal entry for the native addon: the real wrapper is the published
// `sasso/native` subpath (../../wasm/npm/native.mjs — single source of truth);
// this shim exists so in-repo consumers (napi/test.mjs, bench/asyncify --impl)
// keep a stable path next to the crate. Binding resolution inside native.mjs
// falls back to ../../napi/npm/sasso.node in a repo checkout, i.e. the binary
// staged by `bash napi/build.sh` right here.
export * from "../../wasm/npm/native.mjs";
export { default } from "../../wasm/npm/native.mjs";
