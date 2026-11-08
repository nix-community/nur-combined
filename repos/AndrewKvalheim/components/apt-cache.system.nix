{
  imports = [ ../library/apt-cacher-ng.system.nix ];

  config = {
    services.apt-cacher-ng.enable = true;
  };
}
