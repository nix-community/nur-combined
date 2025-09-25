{
  withSystem,
  self,
  inputs,
  ...
}:

withSystem "x86_64-linux" (
  ctx@{
    config,
    inputs',
    system,
    ...
  }:
  let
    inherit (self) lib;
  in
  lib.nixosSystem {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnsupportedSystem = true;
        allowUnfree = true;
        # allowUnfreePredicate =
        #   pkg:
        #   builtins.elem (lib.getName pkg) [
        #     "code"
        #     "vscode"
        #     "steam"
        #     "fcitx5-pinyin-moegirl"
        #     "steam-unwrapped-1.0.0.81"
        #     "steam-unwrapped"
        #     "wechat-uos"
        #     "wechat"
        #     "chromium"
        #     "chromium-unwrapped"
        #   ];
        permittedInsecurePackages = [
          "olm-3.2.16"
        ];
      };
      overlays = lib.hostOverlays { inherit inputs inputs'; };
    };
    specialArgs = {
      inherit
        lib
        self
        inputs
        inputs'
        ;
      inherit (config) packages;
      inherit (lib) data;
      user = "riro";
    };
    modules =
      lib.sharedModules
      ++ [
        ../home.nix
        ./hardware.nix
        ./network.nix
        ./rekey.nix
        ./spec.nix
        ./caddy.nix
        ./backup.nix

        ../persist.nix
        ../secureboot.nix
        ../../packages.nix
        ../../misc.nix
        ../sysvars.nix
        ../graphBase.nix
        (lib.iage "trust")

        ../sysctl-boost.nix
        ../pam.nix
        ../virt.nix

        ../../users.nix

        ../dev.nix
        ../../vms/sep.nix
        ../distributed-build.nix
      ]
      ++ (with inputs; [
        # aagl.nixosModules.default
        disko.nixosModules.default
        # niri.nixosModules.niri
        # nixos-cosmic.nixosModules.default
        # inputs.j-link.nixosModule
      ]);
  }
)
