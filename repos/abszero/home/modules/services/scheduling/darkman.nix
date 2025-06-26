{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.abszero.services.darkman;

  switch-hm-specialisation = spec: ''
    hm_gens=$(${
      if config.nix.package != null then config.nix.package else pkgs.nixVersions.latest
    }/bin/nix-store -q --referrers ~/.local/state/nix/profiles/home-manager)
    "$(${pkgs.toybox}/bin/find $hm_gens -maxdepth 1 -type d -name specialisation)/${spec}/activate"
  '';

  call-screen-transition = ''
    export NIRI_SOCKET="''$(find /run/user/* -maxdepth 1 -name 'niri*.sock' 2>/dev/null | head -n 1)"
    if [[ -n "$NIRI_SOCKET" ]]; then
      echo "Using socket found at $NIRI_SOCKET"
      ${lib.getExe config.programs.niri.package} msg action do-screen-transition
    else
      echo "Cannot find NIRI_SOCKET; skipping screen transition"
    fi
  '';
in

{
  options.abszero.services.darkman = {
    enable = mkEnableOption "darkman day/night command scheduler";
    lightSpecialisation = mkOption {
      type = types.nonEmptyStr;
    };
    darkSpecialisation = mkOption {
      type = types.nonEmptyStr;
    };
  };

  config.services.darkman = mkIf cfg.enable (mkMerge [
    {
      enable = true;
      lightModeScripts."00-switch-hm-specialisation" = switch-hm-specialisation cfg.lightSpecialisation;
      darkModeScripts."00-switch-hm-specialisation" = switch-hm-specialisation cfg.darkSpecialisation;
      settings.usegeoclue = true;
    }
    (mkIf config.programs.niri.enable {
      lightModeScripts."01-call-screen-transition" = call-screen-transition;
      darkModeScripts."01-call-screen-transition" = call-screen-transition;
    })
  ]);
}
