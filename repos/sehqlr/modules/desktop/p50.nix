{ config, lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;

  time.timeZone = "America/Chicago";

  networking.hostName = "p50";
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;

  services.flatpak.enable = true;

  services.jupyterhub = {
    enable = true;
    kernels = {
      nltk = let
        env = (pkgs.python3.withPackages
          (pypkgs: with pypkgs; [ ipykernel nltk matplotlib numpy ]));
      in {
        displayName = "Python 3 for NLP";
        argv = [
          "${env.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
        logo32 =
          "${env}/${env.sitePackages}/ipykernel/resources/logo-32x32.png";
        logo64 =
          "${env}/${env.sitePackages}/ipykernel/resources/logo-64x64.png";
      };
    };
  };

  xdg.portal.enable = true;
}
