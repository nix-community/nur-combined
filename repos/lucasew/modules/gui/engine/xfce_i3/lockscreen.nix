{pkgs, lib, ...}:
with pkgs.custom.colors.colors;
let
  inherit (pkgs) i3lock-color;
  inherit (lib) concatStringsSep;
  locker-params = [
    # "--image" "/etc/wallpaper"
    "--tiling"
    "--ignore-empty-password"
    "--show-failed-attempts"
    "--clock"
    "--pass-media-keys"
    "--pass-screen-keys"
    "--pass-volume-keys"
    "--color=${base00}"
    "--insidever-color=${base05}22"
    "--ringver-color=${base0E}"
    "--inside-color=${base00}"
    "--ring-color=${base0A}"
    "--line-color=${base00}"
    "--separator-color=${base0A}"
    "--verif-color=${base05}"
    "--wrong-color=${base05}"
    "--time-color=${base05}"
    "--date-color=${base05}"
    "--layout-color=${base05}"
    "--keyhl-color=${base08}"
    "--bshl-color=${base08}"
  ];
in {
  programs.xss-lock = {
    enable = true;
    lockerCommand = ''
      ${i3lock-color}/bin/i3lock-color ${concatStringsSep " " (map toString locker-params)}
    '';
    extraOptions = [];
  };
  systemd.user.services.xss-lock.restartIfChanged = true;

}
