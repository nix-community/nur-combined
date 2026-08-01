{ inputs, lib, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    # defaultSopsFile = ./secrets.yaml;
    age.keyFile = lib.mkDefault "/home/iamanaws/.config/sops/age/keys.txt";

    secrets = {
      wireless = {
        sopsFile = ./networks.conf;
        format = "binary";
      };
    };
  };
}
