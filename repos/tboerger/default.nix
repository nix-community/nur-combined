{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  freelook = pkgs.callPackage ./pkgs/freelook { };
  kubectl-ktop = pkgs.callPackage ./pkgs/kubectl-ktop { };
  kubectl-neat = pkgs.callPackage ./pkgs/kubectl-neat { };
  kubectl-oomd = pkgs.callPackage ./pkgs/kubectl-oomd { };
  kubectl-pexec = pkgs.callPackage ./pkgs/kubectl-pexec { };
  kubectl-realname-diff = pkgs.callPackage ./pkgs/kubectl-realname-diff { };
  kubectl-resource-versions = pkgs.callPackage ./pkgs/kubectl-resource-versions { };
  kubectl-view-secret = pkgs.callPackage ./pkgs/kubectl-view-secret { };
  kubectl-whoami = pkgs.callPackage ./pkgs/kubectl-whoami { };
  tailscale-systray = pkgs.callPackage ./pkgs/tailscale-systray { };
}
