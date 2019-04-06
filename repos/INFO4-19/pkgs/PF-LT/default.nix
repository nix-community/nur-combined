{ stdenv, pkgs }:

stdenv.mkDerivation {
    name = "PF-LT";
    shellHook = ''
      echo -e "\e[32m=============================================\e[0m"
      echo -e "\e[32m=== Welcome to PF - LT environment ===\e[0m"
      echo -e "\e[32m=============================================\e[0m"
    '';
    buildInputs = [
        pkgs.ocaml
        pkgs.emacsPackagesNg.tuareg
        pkgs.coq
    ];
}