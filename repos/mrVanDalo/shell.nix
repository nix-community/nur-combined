{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs;
    [
      #travis
      (pkgs.writers.writeBashBin "reformat" ''
        find ${
          toString ./.
        } -type f | egrep "nix$" | while read line ; do ${pkgs.nixfmt}/bin/nixfmt "$line"; done
      '')
    ];
}
