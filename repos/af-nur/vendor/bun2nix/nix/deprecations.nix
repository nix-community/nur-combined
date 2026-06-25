{ lib, inputs, ... }:
let
  throwRemovedV2 =
    name: value:
    builtins.throw ''
      The `bun2nix.lib.''${system}.${name}` function has been 
      removed/replaced/moved with the breaking API changes for `bun2nix` v2.

      Please take a look at the v2 update guide in the documentation for a
      walk through on how to update.

      If this was sprung on you randomly with `nix flake update`,
      please consider pinning your `bun2nix` dependency's version with a 
      `tag` specifier:

      ```nix
      # Put the appropriate version here
      bun2nix.url = "github:nix-community/bun2nix?ref=2.0.0";
      ```

      # Potential Fix:

      > Note: `bun2nix` below corresponds to the `bun2nix` package
      at `inputs.bun2nix.packages.''${system}.default`

      ${value}
    '';

  removedFns = {
    "mkBunDerivation" = ''
      ## Before
      ```nix
      {mkBunDerivation, ...}:
      mkBunDerivation {
        pname = "simple-bun-app";
        version = "1.0.0";

        src = ./.;

        bunNix = ./bun.nix;

        index = "index.ts";
      }
      ```

      ## After
      ```nix
      {bun2nix, ...}:
      bun2nix.mkDerivation {
        pname = "simple-bun-app";
        version = "1.0.0";

        src = ./.;

        bunDeps = bun2nix.fetchBunDeps {
          bunNix = ./bun.nix;
        };

        module = "index.ts";
      }
      ```
    '';
    "mkBunNodeModules" = ''
      ## Before
      ```nix
      {stdenv, mkBunNodeModules, ...}:
      let
        bunNix = import ./bun.nix;
        node_modules = mkBunNodeModules { packages = bunNix };
      in
      stdenv.mkDerivation {
        preBuild = '''
          cp -r ''${node_modules}/. ./node_modules
        ''';

        # <rest of code>
      };
      ```

      ## After
      ```nix
      {stdenv, bun2nix, ...}:
      stdenv.mkDerivation {
        nativeBuildInputs = [
          bun2nix.hook
        ];

        bunDeps = bun2nix.fetchBunDeps {
          bunNix = ./bun.nix;
        };

        # <rest of code>
      };
      ```
    '';
    "writeBunScriptBin" = ''
      ## Before
      ```nix
      {writeBunScriptBin, ...}:
      writeBunScriptBin {
        name = "hello-world";
        text = '''
          import { $ } from "bun";

          await $`echo "Hello World!"`;
        ''';
      }
      ```

      ## After
      ```nix
      {bun2nix, ...}:
      bun2nix.writeBunScriptBin {
        name = "hello-world";
        text = '''
          import { $ } from "bun";

          await $`echo "Hello World!"`;
        ''';
      }
    '';
  };

  systems = import inputs.systems;
in
{
  flake.lib = lib.genAttrs systems (_: builtins.mapAttrs throwRemovedV2 removedFns);
}
