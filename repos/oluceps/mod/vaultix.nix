{
  withSystem,
  inputs,
  self,
  ...
}:
{
  flake.vaultix = {
    nodes =
      let
        inherit (inputs.nixpkgs.lib) filterAttrs elem;
      in
      filterAttrs (
        n: _:
        !elem n [
          # "yidhra"
          "resq"
          "livecd"
          "bootstrap"
          "nodens"
          # "hastur"
          # "kaambl"
        ]
      ) self.nixosConfigurations;
    identity = self + "/sec/age-yubikey-identity-7d5d5540.txt.pub";
    extraRecipients = [ self.data.keys.ageKey ];
    defaultSecretDirectory = "./sec";
    cache = "./sec/.cache";
  };
  flake.modules.nixos.vaultix =
    { pkgs, lib, ... }:
    {
      imports = lib.singleton {
        imports = [ (import (inputs.vaultix.outPath + "/module") { localSelf = self; }) ];
        vaultix.package = withSystem pkgs.stdenv.hostPlatform.system (
          { inputs', ... }: inputs'.vaultix.packages.default
        );
      };
    };
}
