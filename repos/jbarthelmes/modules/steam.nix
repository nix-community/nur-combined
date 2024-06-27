{
  # https://wiki.nixos.org/wiki/Steam
  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };
}
