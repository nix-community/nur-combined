# uses package source sourced from niv
self: super: let
   pkgs = import ../nix ;
   nixLib = pkgs.pkgs.lib;
in
   pkgs.pkgs // {
         lib = nixLib.recursiveUpdate super.lib {
            overlays.nivConfig = pkgs.overlay;
         };
         inherit (pkgs) sources nixos;
   }
