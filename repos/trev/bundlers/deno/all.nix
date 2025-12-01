{ pkgs }:
let
  # from https://docs.deno.com/runtime/reference/cli/compile/#supported-targets
  targets = [
    "x86_64-pc-windows-msvc"
    "x86_64-apple-darwin"
    "aarch64-apple-darwin"
    "x86_64-unknown-linux-gnu"
    "aarch64-unknown-linux-gnu"
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "deno-${target}" (
      drv:
      import ./. {
        inherit
          pkgs
          drv
          target
          ;
      }
    )
  ) targets
)
