{ pkgs }:

pkgs.lib.fix (x: (import ./pkgs) (x // pkgs) pkgs)
