{ inputs, modules, ... }:
let
  local-modules = with modules; [
    nix.default
  ];
in
inputs.nixos-generators.nixosGenerate {
  system = "x86_64-linux";
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
      environment.systemPackages = with pkgs; [
        ethtool
        inputs.disko.packages."x86_64-linux".disko
      ];
      environment.etc."nixos/disko.nix".source = ../_hosts/local/disko.nix;
    })
  ];
  format = "install-iso";
}
