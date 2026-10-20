let
  flake = builtins.getFlake (toString ../..);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
  packages = import ../../lib/package-set.nix {
    inherit pkgs;
    packageRoot = ./fixtures/packages;
  };
  raw = pkgs.callPackage ./fixtures/packages/example/default.nix { };
  standard = import ../../default.nix { inherit pkgs; };
  standardPackages = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) standard;
  metadata = import ../../default.nix { pkgs = null; };
  overlayPackages = (pkgs.extend (import ../../overlay.nix)).nur-lihaoze123;
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
assert builtins.attrNames standardPackages == builtins.attrNames flake.packages.x86_64-linux;
assert builtins.all
  (name: standardPackages.${name}.drvPath == flake.packages.x86_64-linux.${name}.drvPath
    && standardPackages.${name}.drvPath == overlayPackages.${name}.drvPath)
  (builtins.attrNames standardPackages);
assert builtins.attrNames metadata.nixosModules == [ "computer-use" "edunet" "gxfp5130-chicago" ];
assert builtins.all builtins.isPath (builtins.attrValues metadata.nixosModules);
true
