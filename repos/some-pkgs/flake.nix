{
  description = "Some NUR repository";
  inputs.nixpkgs.url = "github:SomeoneSerge/nixpkgs/less-unstable";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = builtins.filter (name: builtins.hasAttr name nixpkgs.legacyPackages) [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f system);

      supportsPlatform = system: name: package:
        let s = builtins.elem system (package.meta.platforms or [ ]);
        in if s then s else lib.warn "${name} seems to not be support ${system}" s;

      notBroken = name: pkg:
        let
          s = (builtins.tryEval (builtins.seq pkg.outPath true)).success;
          marked = (builtins.tryEval (pkg.meta.broken or false)).value;
        in
        if s || marked then s else lib.warn "${name} must have broken dependencies" s;

      isRedist = packages: name: pkg:
        let
          isFree = pkg.meta.license.free or true;
          allowUnfree = packages.config.allowUnfree or false;
          ok = isFree || allowUnfree;
        in
        if ok then ok
        else lib.warn "not allowed to include ${name}; it's ${if isFree then "free" else "unfree"} and we ${if allowUnfree then "" else "don't "}allow unfree" ok;

      reservedName = name: builtins.elem name [
        "lib"
        "python"
        "python3"
      ];

      filterUnsupported = system: packages:
        let
          filters = [
            (name: _: ! reservedName name)
            (name: attr: attr ? type && attr.type == "derivation")
            (supportsPlatform system)
            (isRedist packages)
            notBroken # tryEval is the last
          ];
          f = name: package: builtins.all (f: f name package) filters;
        in
        lib.filterAttrs f packages;

      overlay = import ./overlay.nix;

      pkgs = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      });

      newAttrs = forAllSystems (system: pkgs.${system}.some-pkgs);
      supportedPkgs = lib.mapAttrs filterUnsupported newAttrs;

      outputs = {
        inherit overlay;

        packages = supportedPkgs;
        legacyPackages = newAttrs;
      };
    in
    outputs;
}
