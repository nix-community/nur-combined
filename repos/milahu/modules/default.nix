{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;

  proftpd = ./services/networking/proftpd.nix;

  redis-commander = ./services/database/redis-commander.nix;
}
