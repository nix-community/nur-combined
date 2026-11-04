{ pkgs, nixpkgs, self, system }:
let
  lib = pkgs.lib;

  nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.default
      {
        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
        system.stateVersion = "25.11";
        programs.dartotsu = {
          enable = true;
          channel = "stable";
        };
      }
    ];
  };

  nixosPrerelease = nixos.extendModules {
    modules = [ { programs.dartotsu.channel = lib.mkForce "prerelease"; } ];
  };

  hm = lib.evalModules {
    modules = [
      self.homeManagerModules.default
      {
        options = {
          home.packages = lib.mkOption { type = lib.types.listOf lib.types.package; default = [ ]; };
          xdg.mimeApps.enable = lib.mkOption { type = lib.types.bool; default = false; };
          xdg.mimeApps.defaultApplications = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
          };
        };
        config = {
          _module.args.pkgs = pkgs;
          programs.dartotsu.enable = true;
        };
      }
    ];
  };

  assertEq = name: a: b:
    if a == b then true else throw "${name}: expected ${builtins.toJSON b}, got ${builtins.toJSON a}";

  results = [
    (assertEq "nixos installs the stable package"
      (map (p: p.name) (builtins.filter (p: p ? channel) nixos.config.environment.systemPackages))
      [ self.packages.${system}.stable.name ])
    (assertEq "nixos registers the dartotsu scheme"
      nixos.config.xdg.mime.defaultApplications."x-scheme-handler/dartotsu"
      "dartotsu.desktop")
    (assertEq "prerelease does not take over link handlers"
      (nixosPrerelease.config.xdg.mime.defaultApplications ? "x-scheme-handler/dartotsu")
      false)
    (assertEq "home-manager installs the package"
      (map (p: p.name) hm.config.home.packages)
      [ self.packages.${system}.stable.name ])
    (assertEq "home-manager registers link handlers"
      hm.config.xdg.mimeApps.defaultApplications."x-scheme-handler/mangayomi"
      "dartotsu.desktop")
    (assertEq "overlay exposes every channel"
      (builtins.attrNames (lib.filterAttrs (n: _: lib.hasPrefix "dartotsu" n)
        (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        })))
      [ "dartotsu" "dartotsu-alpha" "dartotsu-prerelease" ])
  ];
in
(lib.mapAttrs (_: p: p) {
  inherit (self.packages.${system}) stable prerelease alpha;
})
// {
  modules = pkgs.writeText "dartotsu-module-checks" (
    builtins.toJSON (builtins.deepSeq results results)
  );
}
