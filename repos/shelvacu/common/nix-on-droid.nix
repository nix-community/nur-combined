{
  config,
  lib,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkDefault;
in
lib.optionalAttrs (vacuModuleType == "nix-on-droid") {
  nix.substituters = lib.mkForce config.vacu.nix.substituterUrls;
  nix.trustedPublicKeys = lib.mkForce config.vacu.nix.trustedKeys;
  vacu.shell.functionsDir = "${config.user.home}/.nix-profile/share/vacufuncs";
  environment.etc.bashrc.text = config.vacu.shell.interactiveLines;
  environment.etc.profile.text = config.vacu.shell.interactiveLines;
  environment.etc."vacu/info.json".text = builtins.toJSON config.vacu.versionInfo;

  vacu.hostName = mkDefault "nix-on-droid";
  vacu.shortHostName = mkDefault "nod";
}
