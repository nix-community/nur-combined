{ pkgs }:
let
  # from https://bun.sh/docs/bundler/executables#supported-targets
  targets = [
    "linux-x64"
    "linux-arm64"
    "windows-x64"
    "darwin-x64"
    "darwin-arm64"
    "linux-x64-musl"
    "linux-arm64-musl"
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "node-bun-${target}" (
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
