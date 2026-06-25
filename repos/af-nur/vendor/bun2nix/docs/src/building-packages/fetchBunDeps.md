# Fetching with `bun2nix.fetchBunDeps`

`fetchBunDeps` is a handy function responsible for creating a [bun compatible cache](https://github.com/oven-sh/bun/blob/642d04b9f2296ae41d842acdf120382c765e632e/docs/install/cache.md#L24) for doing offline installs.

## Example

You should use `fetchBunDeps` in conjunction with the rest of `bun2nix` to build your Bun packages like so:

```nix
{
  bun2nix,
  ...
}:
bun2nix.mkDerivation {
  pname = "workspace-test-app";
  version = "1.0.0";

  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  module = "packages/app/index.js";
}
```

## Arguments

`fetchBunDeps` is designed to offer a number of flexible options for customizing your Bun install process:

| Argument            | Purpose                                                                                                                                                                                                                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bunNix`            | The `bun.nix` file as created by the [bun2nix CLI](../using-the-command-line-tool.md)                                                                                                                                                                                                                   |
| `overrides`         | Allows for modifying packages before install in the Nix store to patch any broken dependencies. See the overriding section below                                                                                                                                                                        |
| `useFakeNode`       | By default, `bun2nix` patches any scripts that use Node in your dependencies to use `bun` as its executable instead. Turning this off will patch them to use `node` instead. This might be useful, if, for example, you need to link to actual Node v8 while building a native addon. Defaults to true. |
| `patchShebangs`     | If scripts in your dependencies should have their shebangs patched or not. Defaults to true.                                                                                                                                                                                                            |
| `autoPatchElf`      | If any elf files that exist in your bun dependencies should be patched. See [`autoPatchelfHook`](https://ryantm.github.io/nixpkgs/hooks/autopatchelf/#setup-hook-autopatchelfhook). Off by default as most builds do not require this.                                                                  |
| `nativeBuildInputs` | Extra native libraries that your NPM dependencies may need. Linked via `autoPatchElf` and will not do anything if that option is not enabled.                                                                                                                                                           |

## Overrides

`fetchBunDeps` provides an overrides api for modifying packages in the Nix store before they become a part of Bun's install cache and ultimately your project's node_modules.

You may want to use this to patch a dependency which, for example, makes a network request during install and fails because it's sandboxed by Nix.

### Type

Each override attribute name must be a key that exists in your `bun.nix` file, and the attribute value must be a function that takes a derivation and returns another one.

### Example

```nix
bunDeps = bun2nix.fetchBunDeps {
  bunNix = ./bun.nix;
    overrides = {
      "typescript@5.7.3" =
        pkg:
        runCommandLocal "override-example" { } ''
          mkdir $out
          cp -r ${pkg}/. $out

          echo "hello world" > $out/my-override.txt
        '';
    };
};

# Assertion will not fail
postBunNodeModulesInstallPhase = ''
  if [ ! -f "node_modules/typescript/my-override.txt" ]; then
    echo "Text file created with override does not exist."
    exit 1
  fi
'';
```

## Operating Details

As mentioned above, the `bun2nix.fetchBunDeps` function produces a `bun` [compatible cache](https://bun.sh/docs/install/cache#global-cache), which allows `bun` to do offline installs through files available in the Nix store.

In general, for a given package, the installation process looks something like:

```nix
# bun.nix contents
"@types/bun@1.2.4" = fetchurl {
  url = "https://registry.npmjs.org/@types/bun/-/bun-1.2.4.tgz";
  hash = "sha512-QtuV5OMR8/rdKJs213iwXDpfVvnskPXY/S0ZiFbsTjQZycuqPbMW8Gf/XhLfwE5njW8sxI2WjISURXPlHypMFA==";
};
```

### 1. Download the package via a fetcher function

First, `bun2nix` deps are downloaded via a Nix [FOD](https://bmcgee.ie/posts/2023/02/nix-what-are-fixed-output-derivations-and-why-use-them/) fetching function.

> For most packages this is [`pkgs.fetchurl`](https://noogle.dev/f/pkgs/fetchurl), and the hash can be taken directly from the `bun.lock` textual lock-file, meaning they don't need to be prefetched.

### 2. Extract the package

By default, fetching packages will produce either a tarball or a flat directory with the contents.

If the package is a tarball, it should be extracted first. Then, both types have their permissions normalized to make sure that scripts are properly executable/readable by the `nixbld` users.

Any references to `node` or `bun` binaries are also fixed up at this stage.

> Unfortunately, NPM dependencies cannot use [`builtins.fetchTarball`](https://noogle.dev/f/builtins/fetchTarball), which would do the fetching and extraction in one build step because it would produce a hash that differs from the one in the Bun lockfile.

### 3. Creating a cache entry

After this point, the packages are all the same shape (a patched flat directory). These are then passed into the `bun2nix.cache-entry-creator` binary, which creates symlinks to where Bun expects to find its packages in its cache.

> This binary is a Zig-implemented command-line utility, because Bun uses a very specific version of [Wyhash](https://github.com/oven-sh/bun/blob/755b41e85bec1744dc2f438f1dfd0e9152d7b62c/src/wyhash.zig), which is vendored into their project, to patch package names before putting them into their cache.

If a package is in a sub-directory like `@types`, it must have appropriate parent directories created too.

```
# Input
"@types/bun@1.2.4"

# Output location
$out/share/bun-cache/@types/bun@1.2.4@@@1
```

```
# Input
"tailwindcss@4.0.0-beta.9"

# Output location
$out/share/bun-cache/tailwindcss@4.0.0-73c5c46324e78b9b@@@1
```

### 4. Forcing use of the cache

Our Bun cache is then forced to be used in the build process by the [hook](./hook.md), which sets `$BUN_INSTALL_CACHE_DIR` to `$out/share/bun-cache`.
