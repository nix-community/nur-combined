{
  pkgs,
  flake,
  system ? pkgs.system,
  ...
}: let
  lib = pkgs.lib;

  home-manager = builtins.getFlake "github:nix-community/home-manager/d441981b200305ebb8e2e2921395f51d207fded6?narHash=sha256-QCgaXEj8036JlfyVM2e5fgKIxoF7IgGRcAi8LkehKvo%3D";

  # Evaluate the Home Manager module to get the package it provides
  hmConfig = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      flake.homeModules.osgrep
      {
        programs.osgrep.enable = true;
        home.stateVersion = "24.05";
        home.username = "test";
        home.homeDirectory = "/home/test";
      }
    ];
  };

  # Extract the osgrep package from the module
  osgrepPackage = hmConfig.config.home.packages;
in
  pkgs.testers.nixosTest {
    name = "osgrep-module-test";

    nodes.machine = {
      # Install the package that the HM module provides
      environment.systemPackages = lib.flatten [osgrepPackage];
    };

    testScript = ''
      start_all()

      # Test that osgrep is available (tests the module installs the package)
      machine.succeed("which osgrep")

      # Test version flag
      machine.succeed("osgrep --version")

      # Test help flag
      machine.succeed("osgrep --help")
    '';
  }
