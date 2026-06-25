# Building with `bun2nix.writeBunApplication`

`writeBunApplication` is provided as a library function as a convenient extension over
[`mkDerivation`](./mkDerivation.md). If you are looking to use `writeBunApplication`, please take a look over there first to familiarize yourself with its arguments.

This function is intended for use building non-compilable programs that run under bun.

> Note: `writeBunApplication` takes heavy inspiration from [`pkgs.writeShellApplication`](https://noogle.dev/f/pkgs/writeShellApplication). Think of it as an alternative which also manages `bun` dependencies.

## When to use:

- If you need something like a [`nextjs`](https://nextjs.org/) server that needs the original source directory **and** a valid `node_modules` to run
- If you want to run a `bunx` binary as if it is a regular system executable with `bun2nix` managed dependencies.

## When to avoid:

- You should avoid this at all if you can bundle your application in a way where it produces a standalone artifact. This could be something like a website, a bun binary, or anything else that doesn't care about the original source. Use the [hook](./hook.md) or the [`mkDerivation`](./mkDerivation.md) to build those kinds of projects instead.

## Example

Currently, basic usage would look something like (to package a [`nextjs`](https://nextjs.org/) server):

```nix
{bun2nix, ...}:
bun2nix.writeBunApplication {
  # Could also be `pname` and `version`
  # See the `mkDerivation` docs if this
  # looks unfamiliar to you
  packageJson = ./package.json;

  src = ./.;

  # Use the `build` script from
  # `package.json` instead of
  # bun's bundler accessed via
  # `bun build`
  #
  # Confusing, isn't it?
  buildPhase = ''
    bun run build
  '';

  # Start script to use to launch
  # your project at runtime
  startScript = ''
    bun run start
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
```

Or, to package an arbitrary `bunx` binary (as long as it's in `bun.nix` somewhere)

```nix
{bun2nix, ...}:
bun2nix.writeBunApplication {
  packageJson = ./package.json;

  src = ./.;

  dontUseBunBuild = true;
  dontUseBunCheck = true;

  startScript = ''
    bunx cowsay "$@"
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
```

Or, to package a simple web server that uses `cowsay` and a runtime environment variable:

```nix
# In your default.nix
{ pkgs, bun2nix, ... }:
bun2nix.writeBunApplication {
  pname = "cowsay-server";
  version = "1.0.0";

  src = ./.;

  startScript = ''
    bun run index.ts
  '';

  runtimeInputs = [ pkgs.cowsay ];
  runtimeEnv = {
    USER = "Nix";
  };

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
```

And the corresponding `index.ts`:

```typescript
import { $ } from "bun";

const user = process.env.USER || "World";

const server = Bun.serve({
  port: 3000,
  async fetch(req) {
    const message = `Hello, ${user}!`;
    const cowsay = await $`cowsay ${message}`.text();
    return new Response(cowsay);
  },
});

console.log(`Listening on http://localhost:${server.port} ...`);
```

## Arguments

The full list of accepted arguments is:

> Additionally, the full range of config options from [`mkDerivation`](./mkDerivation.md) is available too.

| Argument               | Purpose                                                                                                                                                      |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `startScript`          | The script to start your application with.                                                                                                                   |
| `runtimeInputs`        | Runtime nix dependencies your application requires. Defaults to `[]`.                                                                                        |
| `runtimeEnv`           | Runtime environment variables. Defaults to `{}`.                                                                                                             |
| `excludeShellChecks`   | [`shellcheck`](https://www.shellcheck.net/) checks to exclude while checking your `startScript`. Defaults to `[]`.                                           |
| `extraShellCheckFlags` | Extra [`shellcheck`](https://www.shellcheck.net/) flags to run when checking your `startScript`. Defaults to `[]`.                                           |
| `bashOptions`          | [Bash Options](https://gist.github.com/akrasic/380bda362e0420be08709152c91ca1f9) to set for your script. Defaults to `[ "errexit", "nounset", "pipefail" ]`. |
| `inheritPath`          | If your script should use the external `$PATH` when begin ran. Defaults to `false` for purity.                                                               |
