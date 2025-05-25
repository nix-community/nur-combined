{pkgs ? import <nixpkgs> {}}:
import ./pkgs pkgs
// {
    homeManagerModules = import ./modules/home-manager;
}
