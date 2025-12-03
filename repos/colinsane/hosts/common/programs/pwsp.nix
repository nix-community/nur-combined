{ config, ... }:
{
  sane.programs.pwsp = {
    sandbox.method = null;  #< TODO: sandbox

    services.pwsp-daemon = {
      description = "pwsp-daemon (provides a virtual Pipewire mic, which mixes a real mic with a soundboard, controlled by pwsp-gui)";
      command = "pwsp-daemon";
      depends = [ "wireplumber" ];  # or maybe just "pipewire"
      partOf = [ "sound" ];
    };
  };
}
