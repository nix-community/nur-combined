{ pkgs ? import <nixpkgs> {} }:

rec {
  ape = pkgs.callPackage ./pkgs/ape {};
  conmon = pkgs.callPackage ./pkgs/conmon {};
  dobi = pkgs.callPackage ./pkgs/dobi {};
  dep-collector = pkgs.callPackage ./pkgs/dep-collector {};
  envbox = pkgs.callPackage ./pkgs/envbox {};
  go-containerregistry = pkgs.callPackage ./pkgs/go-containerregistry {};
  gogo-protobuf = pkgs.callPackage ./pkgs/gogo-protobuf {};
  knctl = pkgs.callPackage ./pkgs/knctl {};
  krew = pkgs.callPackage ./pkgs/krew {};
  podman = pkgs.callPackage ./pkgs/podman {};
  prm = pkgs.callPackage ./pkgs/prm {};
  protobuild = pkgs.callPackage ./pkgs/protobuild {};
  s2i = pkgs.callPackage ./pkgs/s2i {};
  slirp4netns = pkgs.callPackage ./pkgs/slirp4netns {};
}
