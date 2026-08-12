{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    optionalAttrs
    ;

  cfg = config.my.services.pipewire;
  my = config.my;
in {
  options.my.services.pipewire = {
    enable = mkEnableOption "Pipewire sound backend";
  };

  # HACK: services.pipewire.alsa doesn't exist on 20.09, avoid evaluating this
  # config (my 20.09 machine is a server anyway)
  config = optionalAttrs (options ? services.pipewire.alsa) (mkIf cfg.enable {
    # recommended for pipewire as well
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };

    # FIXME: a shame pactl isn't available by itself, eventually this should be
    #        replaced by pw-cli or a wrapper, I guess?
    environment.systemPackages = [pkgs.pulseaudio];
  });
}
