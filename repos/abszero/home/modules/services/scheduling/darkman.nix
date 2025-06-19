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
    ;
  cfg = config.abszero.services.darkman;

  switch-hm-specialisation =
    spec:
    pkgs.writeShellApplication {
      name = "switch-hm-specialisation-${spec}";

      runtimeInputs = with pkgs; [
        nixVersions.latest
        toybox
      ];

      inheritPath = false;
      excludeShellChecks = [ "SC2086" ];
      bashOptions = [
        "errexit"
        "nounset"
        "pipefail"
        "xtrace"
      ];

      text = ''
        hm_gens=$(nix-store -q --referrers ~/.local/state/nix/profiles/home-manager)
        "$(find $hm_gens -maxdepth 1 -type d -name specialisation)/${spec}/activate"
      '';
    }
    + "/bin/switch-hm-specialisation-${spec}";

  call-screen-transition = toString (pkgs.writeScript "call-screen-transition" ''
    export NIRI_SOCKET="''$(find /run/user/* -maxdepth 1 -name 'niri*.sock' 2>/dev/null | head -n 1)"
    if [[ -n "$NIRI_SOCKET" ]]; then
      echo "Using socket found at $NIRI_SOCKET"
      ${lib.getExe config.programs.niri.package} msg action do-screen-transition
    else
      echo "Cannot find NIRI_SOCKET; skipping screen transition"
    fi
  '');
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

  config.services.darkman = mkIf cfg.enable {
    enable = true;
    lightModeScripts = {
      "00-switch-hm-specialisation" = switch-hm-specialisation cfg.lightSpecialisation;
      "01-call-screen-transition" = call-screen-transition;
    };
    darkModeScripts = {
      "00-switch-hm-specialisation" = switch-hm-specialisation cfg.darkSpecialisation;
      "01-call-screen-transition" = call-screen-transition;
    };
    settings.usegeoclue = true;
  };
}
