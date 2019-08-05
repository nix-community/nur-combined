pkgs: let
  home = ../modules/home;
  nixos = ../modules/nixos;
  system = pkgs.nixos {
    boot.isContainer = true;
    imports = [nixos <home-manager/nixos>];
    home-manager.users.root = _: {
      imports = [home];
    };
  };
in [system]
