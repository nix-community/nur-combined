{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  outputs = { self, nixpkgs, flake-compat }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    rec {
      nixosModules = import ./modules; # NixOS modules
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          qemu = with pkgs; callPackage ./pkgs/applications/virtualization/qemu {
            inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
            inherit (darwin.stubs) rez setfile;
            inherit (darwin) sigtool;
          };
        in
        {
          qemu_kvm = pkgs.lowPrio (qemu.override { hostCpuOnly = true; });
        });
    };
}
