let
  flake = builtins.getFlake (toString ../..);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
  packages = import ../../lib/package-set.nix {
    inherit pkgs;
    packageRoot = ./fixtures/packages;
  };
  raw = pkgs.callPackage ./fixtures/packages/example/default.nix { };
  private = import ../../ci-private.nix {
    inherit (pkgs) lib;
    system = "x86_64-linux";
    packages = {
      unfree = raw.overrideAttrs (_: { meta.license = pkgs.lib.licenses.unfree; });
      broken = raw.overrideAttrs (_: { meta.broken = true; });
      unsupported = raw.overrideAttrs (_: { meta.platforms = [ "aarch64-linux" ]; });
      multiple = raw.overrideAttrs (_: { outputs = [ "out" "dev" ]; });
    };
  };
in
assert builtins.attrNames packages == [ "dependent" "example" ];
assert builtins.isString packages.dependent.outPath;
assert packages.example ? updateScript;
assert packages.example.outPath == raw.outPath;
assert builtins.attrNames private.buildJobPackages == [ "multiple" "unfree" ];
assert builtins.length private.outputPaths == 3;
true
