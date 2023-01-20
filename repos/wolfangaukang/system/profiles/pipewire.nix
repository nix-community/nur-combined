{ lib
, enableAlsa32BitSupport ? true 
}:

let
  inherit (lib) mkForce mkIf;

in {
  # Forcing disable of pulseaudio
  hardware.pulseaudio.enable = mkForce false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = mkIf enableAlsa32BitSupport true;
    };
    jack.enable = true;
    pulse.enable = true;
  };
}