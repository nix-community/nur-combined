{ pkgs, inputs }:
let
  inherit (pkgs) lib;

  linuxSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  vmSystems = {
    alpha = linuxSystems;
    pwnbox = linuxSystems ++ [ "aarch64-darwin" ];
  };

  mkVmApp =
    name:
    let
      vm =
        (inputs.self.nixosConfigurations.${name}.extendModules {
          modules = [
            { virtualisation.vmVariant.virtualisation.host.pkgs = pkgs; }
          ];
        }).config.system.build.vm;
    in
    {
      type = "app";
      program = "${vm}/bin/run-${name}-vm";
    };
in
lib.mapAttrs (name: _: mkVmApp name) (
  lib.filterAttrs (_: systems: lib.elem pkgs.stdenv.hostPlatform.system systems) vmSystems
)
