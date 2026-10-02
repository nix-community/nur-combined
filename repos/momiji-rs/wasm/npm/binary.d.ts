// sasso/binary — the path of the native `sasso` command-line binary that the
// prebuilt platform package ships beside the addon, for a tool that spawns
// the compiler and wants to skip node's start-up (see the README's "Spawning
// the CLI" section).

/**
 * The absolute path of the `sasso` binary prebuilt for this machine, or
 * `null` where there is none (no prebuild for the platform, optional
 * dependencies skipped, or a platform package older than the binary).
 *
 * Throws an `Error` with `code: "SASSO_ADDON_VERSION_MISMATCH"` when the
 * platform package carries a binary but is not the same version as this
 * `sasso`.
 */
export function binaryPath(): string | null;

declare const _default: { binaryPath: typeof binaryPath };
export default _default;
