{ pkgs }:
let
  # from https://bun.sh/docs/bundler/executables#supported-targets
  targets = [
    "bun-linux-x64"
    "bun-linux-arm64"
    "bun-windows-x64"
    "bun-darwin-x64"
    "bun-darwin-arm64"
    "bun-linux-x64-musl"
    "bun-linux-arm64-musl"
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "node-${target}" (
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
