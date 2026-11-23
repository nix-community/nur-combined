{ nixpak }:

final: prev: {
  nixpakApp = import ../lib/nixpak-apps {
    inherit nixpak;
    lib = final.lib;
    pkgs = final;
  };
}
