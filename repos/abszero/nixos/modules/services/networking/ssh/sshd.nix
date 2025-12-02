{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.openssh;
in

{
  options.abszero.services.openssh.enable = mkEnableOption "ssh daemon";

  config.services.openssh = mkIf cfg.enable {
    enable = true;
    startWhenNeeded = true;
    # Obfuscate the port. However, for a proxy server, according to
    # https://geneva.cs.umd.edu/posts/fully-encrypted-traffic/en/, this won't
    # make it less detectable by the GFW.
    ports = [ 1337 ];
  };
}
