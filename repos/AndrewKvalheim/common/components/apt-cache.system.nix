{
  imports = [ ../../packages/apt-cacher-ng.nix ];

  config = {
    services.apt-cacher-ng.enable = true;
  };
}
