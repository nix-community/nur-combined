# Headless server
{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.server;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.server.enable = mkExternalEnableOption config "server profile";

  config = mkIf cfg.enable {
    abszero.profiles.base.enable = true;

    # UTC is the default but we explicitly set it to disallow imperative changing.
    time.timeZone = "UTC";

    fonts.fontconfig.enable = false;

    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      # Obfuscate the port. However, for a proxy server, according to
      # https://geneva.cs.umd.edu/posts/fully-encrypted-traffic/en/, this won't
      # make it less detectable by the GFW.
      ports = [ 1337 ];
    };

    environment.noXlibs = true;
  };
}
