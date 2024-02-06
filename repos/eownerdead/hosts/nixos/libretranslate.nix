{ pkgs, config, ... }:
{
  # imports = [
  #   (pkgs.fetchurl {
  #     url = "https://raw.githubusercontent.com/NixOS/nixpkgs/1568716844520095efde1c22462c5a85b4fcd847/nixos/modules/services/web-apps/libretranslate.nix";
  #     hash = "sha256-I4K59sh9odcCYJLN4BJLKRN2T2SzJHW1Snx6TS+Vxds=";
  #   }).outPath
  # ];


  # services.libretranslate = {
  #   enable = true;
  #   package = pkgs.libretranslate // {
  #     static-compressed = pkgs.libretranslate;
  #   };
  #   domain = "libretranslate.eownerdead.dedyn.io";
  #   configureNginx = true;
  # };

  # Does not work with cuda.
  virtualisation.oci-containers.containers.libretranslate = {
    image = "libretranslate/libretranslate:v1.5.1";
    ports = [ "5000:5000" ];
    volumes = [ "lt-local:/home/libretranslate/.local" ];
  };

  services.nginx.virtualHosts."libretranslate.eownerdead.dedyn.io".locations."/".proxyPass =
    "http://0.0.0.0:5000";

}
