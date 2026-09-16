{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  subconverter = ./services/networking/subconverter.nix;

  # hmModules
  linuxqq-clipsync = ./services/misc/linuxqq-clipsync.nix;
}
