{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.sane;
  pkg =
    if cfg.snapshot
    then pkgs.sane-backends-git
    else pkgs.sane-backends;
  backends = [ pkg ] ++ cfg.extraBackends;
  saneConfig = pkgs.mkSaneConfig { paths = backends; };
  saneExtraConfig = pkgs.runCommand "sane-extra-config"
    { } ''
    cp -Lr '${pkgs.mkSaneConfig { paths = [ pkgs.sane-backends ]; }}'/etc/sane.d $out
    chmod +w $out
    ${concatMapStrings
      (
      c: ''
        f="$out/${c.name}.conf"
        [ ! -e "$f" ] || chmod +w "$f"
        cat ${builtins.toFile "" (c.value + "\n")} >>"$f"
        chmod -w "$f"
      ''
      )
      (mapAttrsToList nameValuePair cfg.extraConfig)}
    chmod -w $out
  '';
in
{
  options = {
    hardware.sane.extraConfig = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      example = { "some-backend" = "# some lines to add to its .conf"; };
    };
  };

  config = mkIf (cfg.enable && cfg.extraConfig != { }) {
    hardware.sane.configDir = saneExtraConfig.outPath;
  };
}
