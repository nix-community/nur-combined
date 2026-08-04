{
  config,
  lib,
  ...
}:

let
  isWaylandWMEnabled = config.programs.sway.enable || config.programs.hyprland.enable;

in
{
  imports = [
    ./xserver.nix
  ];

  environment.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = if isWaylandWMEnabled then "1" else "";
    QT_QPA_PLATFORM = lib.mkIf isWaylandWMEnabled "wayland";
  };
  security.pam.services.swaylock.text =
    if isWaylandWMEnabled then
      ''
        auth include login
      ''
    else
      "";
  services = {
    blueman.enable = true;
    displayManager.ly = {
      enable = true;
      settings =
        let
          base_run_path = "/run/current-system";
          brightnessctl_path = "${base_run_path}/sw/bin/brightnessctl";
          systemctl_path = "${base_run_path}/systemd/bin/systemctl";
        in
        {
          # https://github.com/fairyglade/ly/blob/master/res/config.ini
          allow_empty_password = false;
          animation = "matrix";
          brightness_down_cmd = "${brightnessctl_path} -q s 10%-";
          brightness_down_key = "F8";
          brightness_up_cmd = "${brightnessctl_path} -q s +10%";
          brightness_up_key = "F9";
          clear_password = true;
          sleep_cmd = "${systemctl_path} sleep";
          sleep_key = "F12";
          vi_mode = true;
        };
    };
  };
  systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
}
