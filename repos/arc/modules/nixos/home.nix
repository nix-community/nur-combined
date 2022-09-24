{ lib, homeSettingsWhitelist, config, options, ... }: with lib; let
  cfg = config.home.os;
  inherit (config.home-manager) users;
  arc'lib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arc'lib.unmerged;
  whitelist' = builtins.tryEval homeSettingsWhitelist;
  settingsWhitelist = if options.home.os ? _hasSettingsWhitelist
    then homeSettingsWhitelist
    else [ "systemd" "networking" ];
  warnings = mapAttrsToList (name: user: let
    remaining = removeAttrs user.nixos.settings or { } settingsWhitelist;
  in (map (attr: "home-manager.users.${name}.nixos.settings.${attr} is not whitelisted") (attrNames remaining))) users;
in {
  options.home.os = {
    enable = mkEnableOption "home-manager os integration";
  };
  config = genAttrs settingsWhitelist (key: optionalAttrs cfg.enable (mkMerge (mapAttrsToList (_: user:
    unmerged.merge user.nixos.settings.${key} or [ ]
  ) users))) // {
    warnings = flatten warnings;
  };
}
