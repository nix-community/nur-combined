{ pkgs
, lib
, steam-pkg ? pkgs.steam
}:

let
  inherit (lib) getName;

in {
  programs.steam = {
    enable = true;
    package = steam-pkg;
  };
  nixpkgs.config.allowUnfreePredicate = (
    pkg: builtins.elem (getName pkg) [ "steam" "steam-original" "steam-runtime" ]
  );
  hardware.opengl = {
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    setLdLibraryPath = true;
  };
}