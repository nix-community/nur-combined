# uses package source sourced from niv
self: super: let
   pkgs = import ../nix ;
in
   pkgs.pkgs // {
      lib = super.lib // {
         overlays = super.overlays ++ [pkgs.overlay];
         inherit (pkgs) sources nixos;
      };
   }
