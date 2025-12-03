{
  imports = [
    ./frontproxy.nix
    ./options.nix
    ./services
  ];

  vacu.proxiedServices = {
    vacustore.enable = true;
  };
}
