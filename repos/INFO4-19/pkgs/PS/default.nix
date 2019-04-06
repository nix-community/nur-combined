{ stdenv, pkgs }:

stdenv.mkDerivation {
  name = "PS";
  shellHook = ''
      echo -e "\e[32m=============================================\e[0m"
      echo -e "\e[32m=== Welcome to PS environment ===\e[0m"
      echo -e "\e[32m=============================================\e[0m"
    '';
  buildInputs = [ 
    pkgs.rWrapper
    pkgs.rstudioWrapper
  ];

}


