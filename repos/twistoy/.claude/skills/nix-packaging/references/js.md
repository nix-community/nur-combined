# Package a JavaScript/TypeScript Application with Nix (npm)

Packaging an npm application (`buildNpmPackage`) involves determining the package name, version, and dependencies. The package must be available on the npm registry.

## Normal npm Package

See the example: `resource/claude-code/package.nix`

Key components:

- **Source**: Fetch from npm registry using `fetchzip` with URL pattern:
  ```nix
  url = "https://registry.npmjs.org/@scope/package-name/-/package-name-${version}.tgz";
  ```
  For non-scoped packages, omit the `@scope/` part.

- **Dependencies**: Set `npmDepsHash` (see update workflow below for obtaining the hash)

- **package-lock.json**: Use `postPatch` to copy a local `package-lock.json`:
  ```nix
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';
  ```

- **Build control**: Use `dontNpmBuild = true;` if the package doesn't require a build step (already built on npm registry)

## Updating an Existing npm Package

Besides the general update steps, also update npm-specific fields:

1. **Update package-lock.json**: Generate a new lock file for the target version:

   ```bash
   # Find the latest version (or specific version)
   npm i --package-lock-only @anthropic-ai/claude-code@"$version"
   # Remove package.json (not needed for Nix packaging)
   rm -f package.json
   ```

   **Note**: If `npm` is not installed, use `nix-shell` to run it:
   ```bash
   nix-shell -p nodejs --run "npm i --package-lock-only @anthropic-ai/claude-code@\"$version\""
   rm -f package.json
   ```

   Copy the generated `package-lock.json` to your package directory.

2. **Update hashes**: Both `hash` (source) and `npmDepsHash` need updating.

   **Method 1: Let Nix tell you**
   - Set `hash = "";` and run `nix build`. Copy the correct hash from the error message.
   - Set `npmDepsHash = "";` and run `nix build`. Copy the correct hash from the error message.

   **Method 2: Calculate directly**
   ```bash
   # For source hash
   nix-prefetch-url --type sha256 --unpack https://registry.npmjs.org/@scope/package/-/package-${version}.tgz
   nix hash convert --hash-algo sha256 <old-hash>
   ```

3. **Check for breaking changes**: New versions may:
   - Change build requirements (update `dontNpmBuild` or add build dependencies)
   - Require different Node.js versions (update `nodejs` attribute, e.g., `nodejs_20`)
   - Add new environment variables or runtime requirements

## Common Patterns

### Specify Node.js Version

For compatibility, especially on Darwin with sandboxed builds:

```nix
buildNpmPackage rec {
  nodejs = nodejs_20;
  # ...
}
```

### Disable Auto-Build

If the package is pre-built on the npm registry:

```nix
dontNpmBuild = true;
```

### Set Environment Variables

Use `postInstall` to wrap the binary with required environment variables:

```nix
postInstall = ''
  wrapProgram $out/bin/your-binary \
    --set ENV_VAR value \
    --unset UNWANTED_VAR
'';
```

### Handle Optional Dependencies

npm packages often have platform-specific optional dependencies (like Sharp's native bindings). These are automatically handled by `buildNpmPackage` based on the `package-lock.json`.

