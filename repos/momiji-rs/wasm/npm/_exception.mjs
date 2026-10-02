// The two names every engine exports and the CLI tests against, in a module of
// their own: `_loader.mjs` (wasm) and `_nativecore.mjs` (the addon) both
// re-export these, so `e instanceof Exception` holds whichever engine threw,
// and the CLI's native path can load them without the 1000-line wasm loader
// (4.4 ms of a 48 ms one-entry compile, measured 2026-10-02; #272).

/**
 * A Sass compilation error. Approximates the dart-sass `Exception`:
 * `instanceof Error`, `name === "Exception"`, plus `sassMessage` (the message
 * without the leading `Error: `). Structured `span` data awaits a later release.
 */
export class Exception extends Error {
  constructor(message, sassMessage, span) {
    super(message);
    this.name = "Exception";
    // dart-sass `sassMessage` is the raw one-line message (no "Error:" header /
    // snippet); fall back to stripping the header off the rendered block.
    this.sassMessage = sassMessage ?? message.replace(/^Error:\s*/, "");
    if (span) this.span = span;
  }
  toString() {
    return this.message;
  }
}

/** dart-sass `Logger` namespace. `Logger.silent` discards all warnings/debugs. */
export const Logger = {
  silent: { warn() {}, debug() {} },
};
