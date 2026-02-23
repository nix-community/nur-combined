{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./users
    ./programs
  ];

  config = {
    sops = {
      defaultSopsFile = ../../secrets.yaml;
      age = {
        keyFile = "${config.home.homeDirectory}/${
          if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config"
        }/sops/age/keys.txt";
      };
    };
    home.packages = lib.optionals (config.launchd.agents ? sops-nix) [
      (pkgs.writeShellScriptBin "sops-nix-user" "${config.launchd.agents.sops-nix.config.Program}")
    ];
  };
}
