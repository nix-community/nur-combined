// The syntax codes the core takes, shared by the wasm importer chain and the
// native engine. Apart from `_importer.mjs` so the CLI's native path can
// name a syntax without loading the importer chain (#272).

import { extname } from "node:path";

const SYNTAX_SCSS = 0;
const SYNTAX_SASS = 1;
const SYNTAX_CSS = 2;

/** Map a dart-sass syntax string to the wasm syntax code. */
export function syntaxCode(syntax) {
  if (syntax === "indented" || syntax === "sass") return SYNTAX_SASS;
  if (syntax === "css") return SYNTAX_CSS;
  return SYNTAX_SCSS;
}

/** The syntax code for a resolved file path, from its extension. */
export function syntaxForPath(p) {
  const ext = extname(p).toLowerCase();
  if (ext === ".sass") return SYNTAX_SASS;
  if (ext === ".css") return SYNTAX_CSS;
  return SYNTAX_SCSS;
}
