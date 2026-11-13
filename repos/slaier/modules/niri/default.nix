{ lib, pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    fuzzel
    nautilus
    niriswitcher
    swaylock
    tauon
    wl-clipboard-rs
    xwayland-satellite
    (writeShellScriptBin "amdgpu-pcie-recover" ''
      set -eu
      for d in /sys/class/drm/card*/device; do
        [ -f "$d/pp_dpm_pcie" ] || continue
        [ -r "$d/current_link_speed" ] || continue
        [ -r "$d/max_link_speed" ] || continue
        cur=$(cat "$d/current_link_speed")
        max=$(cat "$d/max_link_speed")
        echo "amdgpu-pcie-recover: $cur -> $max" >&2
        [ "$cur" = "$max" ] && continue
        echo manual > "$d/power_dpm_force_performance_level"
        echo 1 > "$d/pp_dpm_pcie"
        echo auto > "$d/power_dpm_force_performance_level"
        echo "amdgpu-pcie-recover: done" >&2
      done
    '')
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.tuigreet} --cmd niri-session";
    };
  };

  # Recover AMD GPU PCIe link speed after display wake: DPM downclocks to
  # Gen1 on display-off and fails to raise it again automatically.
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/amdgpu-pcie-recover";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
