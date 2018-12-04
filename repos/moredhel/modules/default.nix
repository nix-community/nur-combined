{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  machines = {
    turtaw = import ./machines/turtaw.nix;
    vps12 = import ./machines/vps12.nix;
  };

  core = {
    common = import ./core/common.nix;
    deprecated = import ./core/deprecated.nix;
    pkgs = import ./core/package-list.nix;
  };

  my_udev = import ./my_udev.nix;
}

