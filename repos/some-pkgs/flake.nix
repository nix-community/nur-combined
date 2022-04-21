{
  description = "Some NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
          marked = pkg.meta.broken or false;
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

      filterUnsupported = system: packages:
        let
          filters = [
            (name: attr: attr ? type && attr.type == "derivation")
            (supportsPlatform system)
            (isRedist packages)
            notBroken # tryEval is the last
          ];
          f = name: package: builtins.all (f: f name package) filters;
        in
        lib.filterAttrs f packages;

      importPkgs = system: import ./default.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      };
      allAttrs = forAllSystems (system: importPkgs system);
      allPackages = lib.mapAttrs (system: packages: builtins.removeAttrs packages [ "lib" "overlays" "modules" ]) allAttrs;
      supportedPackages = lib.mapAttrs filterUnsupported allPackages;
      outputs = {
        packages = supportedPackages;
        overlays = allAttrs.x86_64-linux.overlays;
        legacyPackages = allAttrs;
      };
    in
    outputs;
}
