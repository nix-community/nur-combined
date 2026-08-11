# Building with `bun2nix.hook`

The `bun2nix` hook provides a simple way to extend an existing derivation with Bun dependencies by way of a [setup hook](https://nixos.org/manual/nixpkgs/unstable/#sec-pkgs.makeSetupHook).

This is especially useful for building things like websites or other artifacts that have a build artifact that is not an executable, or for building polyglot projects that need Bun dependencies on hand.

> [`mkDerivation`](./mkDerivation.md) is a thin wrapper over this with `stdenv.mkDerivation` with some extra goodies for building Bun executables.

## Example

You can use the `bun2nix` hook to integrate with an existing `stdenv.mkDerivation` style function by adding it to `nativeBuildInputs` like so:

```nix
{ stdenv, bun2nix, ... }:
stdenv.mkDerivation {
  pname = "my-react-website";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    bun2nix.hook
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  buildPhase = ''
    bun run build \
      --minify
  '';

  installPhase = ''
    mkdir -p $out/dist

    cp -R ./dist $out
  '';
}
```

## Troubleshooting

The default behavior of `bun2nix` is to use [isolated installs](https://bun.com/docs/pm/isolated-installs#backend-strategies) to install your packages. This may lead to some [strange bugs](https://bun.com/blog/bun-v1.3.2#hoisted-installs-restored-as-default) from time to time, especially if tools expect the hoisted linker. A known cross-platform way to use the hoisted linker instead is:

```nix
bunInstallFlags = if stdenv.hostPlatform.isDarwin [
  "--linker=hoisted"
  "--backend=copyfile" # Unfortunately `clonefile` (default) doesn't seem to work with the nix store's permissions, `hardlink` may work too (untested)
] else [
  "--linker=hoisted"
];
```

## Useful Functional Information

The `bun2nix` hook installs the fake [Bun install cache](https://github.com/oven-sh/bun/blob/642d04b9f2296ae41d842acdf120382c765e632e/docs/install/cache.md#L24) created by [`fetchBunDeps`](./fetchBunDeps.md) at `$BUN_INSTALL_CACHE_DIR`.

This is then installed into your repo via a regular `bun install` during `bunNodeModulesInstallPhase`, which runs before the `buildPhase`.

### Workspace catalogs

Projects that use Bun's [`catalog:` protocol](https://bun.com/docs/pm/catalogs) work out of the box. Because `bun install` re-resolves `catalog:` specifiers against the registry even with a fully populated cache, the hook runs `bunResolveCatalogRefs` immediately before `bun install`: it reads the exact pinned version for each package from `bun.lock` and rewrites every `catalog:` reference (in `bun.lock`'s `workspaces` section and each workspace `package.json`) to that exact version, or to `workspace:*` for workspace packages. Both the default catalog and named catalogs (`catalog:<name>`) are handled. The rewrite is a no-op when the lockfile contains no `catalog:` references.

## Arguments

The full list of extra arguments `bun2nix.hook` adds to a derivation are:

| Argument                  | Purpose                                                                                                                                                                                                                                                                                       |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bunDeps`                 | The output of [`fetchBunDeps`](./fetchBunDeps.md) (or any other Nix derivation which produces a Bun-compatible install cache). This is required.                                                                                                                                              |
| `bunRoot`                 | Change the root of the project to a subdirectory where all the commands are run in. Must be a string name representing the subdirectory and not a nix path literal.                                                                                                                           |
| `bunBuildFlags`           | Flags to pass to Bun in the default Bun build phase                                                                                                                                                                                                                                           |
| `bunCheckFlags`           | Flags to pass to Bun in the default Bun check phase                                                                                                                                                                                                                                           |
| `bunInstallFlags`         | Flags to pass to `bun install`. If not set these default to "--linker=isolated --backend=symlink" on `aarch64-darwin` or "--linker=isolated" on other systems                                                                                                                                 |
| `dontRunLifecycleScripts` | By default, after `bunNodeModulesInstallPhase` runs `bun install --ignore-scripts`, `bunLifecycleScriptsPhase` runs any missing lifecycle scripts after making the `node_modules` directory writable and executable. This attribute can be used to disable running `bunLifecycleScriptsPhase` |
| `dontUseBunPatch`         | Don't patch any shebangs in your `src` directory to use Bun as their interpreter                                                                                                                                                                                                              |
| `dontUseBunBuild`         | Disable the default build phase                                                                                                                                                                                                                                                               |
| `dontUseBunCheck`         | Disable the default check phase                                                                                                                                                                                                                                                               |
| `dontUseBunInstall`       | Disable the default install phase                                                                                                                                                                                                                                                             |

## New Build Phases

The `bun2nix` hook introduces a number of new build phases which are worth knowing about:

> These all have `pre` and `post` run hooks available

| Phase                        | Purpose                                                                                     |
| ---------------------------- | ------------------------------------------------------------------------------------------- |
| `bunSetInstallCacheDirPhase` | Sets up the bun cache to link to the prebuilt one in the nix store                          |
| `bunPatchPhase`              | Before doing anything, patch shebangs of your local scripts to use Bun as their interpreter |
| `bunNodeModulesInstallPhase` | Runs `bun install` in your `src` repo                                                       |
| `bunLifecycleScriptsPhase`   | Runs any Bun lifecycle scripts (i.e., "install", etc.) after making `node_modules` writable |
