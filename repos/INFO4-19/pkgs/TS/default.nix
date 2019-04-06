{ stdenv, pkgs }:

stdenv.mkDerivation {
    name = "TS";
    shellHook = ''
      echo -e "\e[32m=============================================\e[0m"
      echo -e "\e[32m=== Welcome to TS environment ===\e[0m"
      echo -e "\e[32m=============================================\e[0m"
    '';
    buildInputs = [
        pkgs.python
        pkgs.vscode
    ];
}