{ pkgs ? import <nixpkgs> {} }:
{
   packageOverrides = pkgs: {

     # R environnement
     rEnv = pkgs.rWrapper.override {
       packages = with pkgs.rPackages; [ 

           ########################################
           # You can list your R packages here
           ########################################
           diversitree EMC

       ];
     };

     # Python environment
     pythonEnv = pkgs.python3.withPackages (ps: with ps; [

           ########################################
           # You can list your python packages here: 
           ########################################
           numpy ipython virtualenv pip 

     ]);

     # NUR packages
     # See https://github.com/Gricad/nur-packages
     nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
         inherit pkgs;
     };
   };

     # Allow to build unfree packages
     allowUnfree = true;
}
