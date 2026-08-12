{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.firefox-webserial;

  installdir = ".mozilla/native-messaging-hosts";
in
{
  options.firefox-webserial = {
    enable = lib.mkEnableOption "Install and enable firefox-webserial";
  };

  config = lib.mkIf (cfg.enable) {
    home.file = {
      "${installdir}/io.github.kuba2k2.webserial.json".text = builtins.toJSON {
        name = "io.github.kuba2k2.webserial";
        description = "WebSerial for Firefox";
        path = "${config.home.homeDirectory}/${installdir}/firefox-webserial";
        type = "stdio";
        allowed_extensions = [ "webserial@kuba2k2.github.io" ];
      };

      "${installdir}/firefox-webserial" = {
        source = pkgs.fetchurl {
          url = "https://github.com/kuba2k2/firefox-webserial/releases/download/v0.4.0/firefox-webserial-linux-x86-64";
          sha256 = "sha256-xzIggoB/ETYwS5sCN/HMeNYVGNjH04cZ4xyACKDgtng=";
        };
        executable = true;
      };
    };
  };
}
