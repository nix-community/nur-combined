{ config, pkgs, lib, ... }:
let
  inherit (lib) version;

  settings = if version > "23.05" then {
    settings.PasswordAuthentication = true;
  } else {
    passwordAuthentication = false;
  };

  agenixPresent = builtins.hasAttr "age" config;

  users = builtins.filter (x: x.isNormalUser)
    (builtins.attrValues config.users.users);

  sshKeys = builtins.foldl' (a: b: a // b) { } (builtins.map (user:
    (builtins.foldl' (a: b: a // b) { } (builtins.map (x: {
      "${lib.strings.removeSuffix ".age" x}" = {
        file = ../../secrets/ssh/${x};
        mode = "0400";
        owner = user.name;
      };
    }) (builtins.filter (z:
      (lib.strings.hasInfix "id-ed25519" z && lib.strings.hasInfix user.name z))
      (builtins.attrNames (builtins.readDir ../../secrets/ssh)))))) users);
in {
  age.secrets = sshKeys;

  services.openssh = { enable = true; } // settings;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
