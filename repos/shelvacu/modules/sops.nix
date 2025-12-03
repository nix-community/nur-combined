{
  config,
  lib,
  inputs,
  vacuRoot,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.sops;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  options.vacu.sops = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    secretsPath = mkOption {
      type = types.path;
      default = /${vacuRoot}/secrets;
      defaultText = "<vacuRoot>/secrets";
    };
  };
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = lib.mkDefault (cfg.secretsPath + "/hosts/${config.vacu.hostName}.yaml");
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      gnupg.sshKeyPaths = [ ]; # explicitly empty to disable gnupg; I don't use it and it takes up space on minimal configs
    };
  };
}
