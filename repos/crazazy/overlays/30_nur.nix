self: super: let
   inherit (builtins) fetchTarball;
   nur = super.callNixPackage (
      { pkgs }:
      import super.lib.srcs.user-pkgs { inherit pkgs; nurpkgs = pkgs; }
      ) {};
   in
   { inherit (nur) repos repo-sources; }
