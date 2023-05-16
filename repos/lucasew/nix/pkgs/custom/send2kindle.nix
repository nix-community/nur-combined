{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellScriptBin "send2kindle" (pkgs.wrapDotenv "send2kindle.env" ''${pkgs.send2kindle}/bin/send2kindle "$@"'')

