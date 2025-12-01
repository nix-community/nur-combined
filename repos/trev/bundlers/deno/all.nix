{ pkgs }:
let
  # from https://docs.deno.com/runtime/reference/cli/compile/#supported-targets
  targets = [
    {
      name = "x86_64-pc-windows-msvc";
      normalized = "x86_64-windows";
    }
    {
      name = "x86_64-apple-darwin";
      normalized = "x86_64-darwin";
    }
    {
      name = "aarch64-apple-darwin";
      normalized = "aarch64-darwin";
    }
    {
      name = "x86_64-unknown-linux-gnu";
      normalized = "x86_64-linux";
    }
    {
      name = "aarch64-unknown-linux-gnu";
      normalized = "aarch64-linux";
    }
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "deno-${target.normalized}" (
      drv:
      import ./. {
        inherit pkgs drv;
        target = target.name;
        normalized = target.normalized;
      }
    )
  ) targets
)
