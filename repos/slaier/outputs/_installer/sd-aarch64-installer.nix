{ inputs, modules, root, ... }:
let
  local-modules = with modules; [
    nix.default
    root.nixosModules.phicomm-n1
  ];
in
inputs.nixos-generators.nixosGenerate {
  system = "aarch64-linux";
  modules = local-modules ++ [
    {
      _module.args = {
        inherit inputs;
      };
    }
    ({ lib, ... }: {
      options.sops = lib.mkSinkUndeclaredOptions { };
    })
    ({ pkgs, ... }: {
      sdImage = {
        populateFirmwareCommands = ''
          cp ${root.packages."aarch64-linux".uboot-phicomm-n1}/{s905_autoscript,uboot} firmware/
        '';
        compressImage = false;
      };

      environment.systemPackages = with pkgs; [
        ethtool
        inputs.disko.packages."aarch64-linux".disko
      ];
    })
  ];
  format = "sd-aarch64-installer";
}
