// sasso — size-optimized (`-Oz`) wasm build (default).
// For ~2x throughput at a larger module, import "sasso/speed".
// Public API mirrors the dart-sass *modern* JS API (drop-in for `sass`).
// Sync APIs use ./sasso.wasm; the async APIs use the asyncify'd ./sasso.async.wasm
// (loaded lazily) so asynchronous importers can suspend the engine.
import { makeApi, Exception, info, Logger } from "./_loader.mjs";
import { valueApi } from "./_value.mjs";

const api = makeApi(
  new URL("./sasso.wasm", import.meta.url),
  new URL("./sasso.async.wasm", import.meta.url),
);

export const compile = api.compile;
export const compileAsync = api.compileAsync;
export const compileString = api.compileString;
export const compileStringAsync = api.compileStringAsync;
export const initCompiler = api.initCompiler;
export const initAsyncCompiler = api.initAsyncCompiler;
export const configure = api.configure;
export { Exception, info, Logger };
// The dart-sass Value type system, for custom `functions`.
export {
  Value,
  SassBoolean,
  SassColor,
  SassList,
  SassArgumentList,
  SassMap,
  SassNumber,
  SassString,
  SassCalculation,
  CalculationOperation,
  SassFunction,
  SassMixin,
  sassTrue,
  sassFalse,
  sassNull,
} from "./_value.mjs";
export default { ...api, Exception, Logger, ...valueApi };
