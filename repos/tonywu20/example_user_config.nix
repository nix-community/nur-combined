{ pkgs ? import <nixpkgs> {} }:
{
   packageOverrides = pkgs: {

     # R environnement
     rEnv = pkgs.rWrapper.override {
       packages = with pkgs.rPackages; [ 

           #################################################
           # You can list your R packages below and intall
           # an R environement with:
           #      nix-env -f "<nixpkgs>" -iA rEnv
           #################################################
           diversitree EMC

       ];
     };

     # Python environment
     pythonEnv = pkgs.python3.withPackages (ps: with ps; [

           #################################################
           # You can list your python packages below and 
           # install a python environement with:
           #      nix-env -f "<nixpkgs>" -iA pythonEnv
           #################################################
           numpy ipython virtualenv pip notebook

     ]);

     ########################################################
     # NUR packages
     # See https://github.com/Gricad/nur-packages
     # To get the list of available packages:
     #     nix-env -f "<nixpkgs>" -qaP -A nur.repos.gricad
     # To install a Gricad package (hello example here):
     #     nix-env -f "<nixpkgs>" -iA nur.repos.gricad.hello
     ########################################################

     nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
         inherit pkgs;
     };
   };

     # Allow to build unfree packages
     allowUnfree = true;
}
