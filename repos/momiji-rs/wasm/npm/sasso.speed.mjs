// sasso/speed — speed-optimized (`-O3`) wasm builds.
// Larger modules (~2x size) for ~2x compile throughput; same API and output
// as the default "sasso" entry point. Both the sync APIs and the async APIs
// (asyncify'd module) run `-O3` builds, so bundler pipelines that only call
// compileStringAsync get speed-class engine time too.
import { makeApi, Exception, info, Logger } from "./_loader.mjs";
import { valueApi } from "./_value.mjs";

const api = makeApi(
  new URL("./sasso.speed.wasm", import.meta.url),
  new URL("./sasso.speed.async.wasm", import.meta.url),
);

export const compile = api.compile;
export const compileAsync = api.compileAsync;
export const compileString = api.compileString;
export const compileStringAsync = api.compileStringAsync;
export const initCompiler = api.initCompiler;
export const initAsyncCompiler = api.initAsyncCompiler;
export const configure = api.configure;
export { Exception, info, Logger };
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
