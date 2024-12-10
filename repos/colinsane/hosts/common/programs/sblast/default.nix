# blast: tunnel audio from a pulseaudio sink to a UPnP/DLNA device (like a TV).
# - expect 7s of latency
# - can cast the default sink, or create a new one "blast.monitor"
#   and either assign that to default or assign apps to it.
# compatibility:
# - there is no single invocation which will be compatible with all known devices.
# - sony tv:
#  - `blast` (default): WORKS
#  - `-usewav`: FAILS
# - LG TV:
#   - `-usewav`: WORKS!
#   - `-useaac`: FAILS
#   - `-useflac`: FAILS
#   - `-uselpcm`: FAILS
#   - `-uselpcmle`: FAILS
#   - `-format aac`: FAILS
#   - `-bitrate 128`: FAILS
#   - `-nochunked`: FAILS
#   - `-format "ogg" -mime 'audio/x-opus+ogg'`: FAILS
#   - `-mime audio/ac3 -format ac3`: FAILS
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sblast;
in
{
  sane.programs.sblast = {
    sandbox.whitelistAudio = true;
    sandbox.net = "clearnet";
  };

  sane.programs.blast-to-default = {
    # helper to deal with blast's interactive CLI
    packageUnwrapped = pkgs.static-nix-shell.mkPython3 {
      pname = "blast-to-default";
      pkgs = [ "sblast" ];
      srcRoot = ./.;
    };
    sandbox.whitelistAudio = true;
    sandbox.net = "clearnet";
    #v  else it fails to reap its children (or, maybe, it fails to hook its parent's death signal?)
    #v  might be possible to remove this, but kinda hard to see a clean way.
    sandbox.keepPidsAndProc = true;
    suggestedPrograms = [ "sane-die-with-parent" "sblast" ];
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enabled [ 9000 ];
}
