{ pkgs ? import <nixpkgs> {} }:

rec {
  # Mine
  ape = pkgs.callPackage ./pkgs/ape {};
  fhs-std = pkgs.callPackage ./pkgs/fhs/std.nix {};
  nr = pkgs.callPackage ./pkgs/nr {};
  ram = pkgs.callPackage ./pkgs/ram {};
  sec = pkgs.callPackage ./pkgs/sec {};
  systemd-email = pkgs.callPackage ./pkgs/systemd-email {};
  yak = pkgs.callPackage ./pkgs/yak {};

  # Maybe upstream
  athens = pkgs.callPackage ./pkgs/athens {};
  dobi = pkgs.callPackage ./pkgs/dobi {};
  dep-collector = pkgs.callPackage ./pkgs/dep-collector {};
  envbox = pkgs.callPackage ./pkgs/envbox {};
  esc = pkgs.callPackage ./pkgs/esc {};
  go-containerregistry = pkgs.callPackage ./pkgs/go-containerregistry {};
  gogo-protobuf = pkgs.callPackage ./pkgs/gogo-protobuf {};
  goreturns = pkgs.callPackage ./pkgs/goreturns {};
  gorun = pkgs.callPackage ./pkgs/gorun {};
  govanityurl = pkgs.callPackage ./pkgs/govanityurl {};
  knctl = pkgs.callPackage ./pkgs/knctl {};
  ko = pkgs.callPackage ./pkgs/ko {};
  kss = pkgs.callPackage ./pkgs/kss {};
  kubernix = pkgs.callPackage ./pkgs/kubernix {};
  krew = pkgs.callPackage ./pkgs/krew {};
  oc = pkgs.callPackage ./pkgs/oc {};
  openshift-install = pkgs.callPackage ./pkgs/openshift-install {};
  operator-sdk = pkgs.callPackage ./pkgs/operator-sdk {};
  prm = pkgs.callPackage ./pkgs/prm {};
  protobuild = pkgs.callPackage ./pkgs/protobuild {};
  rmapi = pkgs.callPackage ./pkgs/rmapi {};
  s2i = pkgs.callPackage ./pkgs/s2i {};
  slirp4netns = pkgs.callPackage ./pkgs/slirp4netns {};
  tkn = pkgs.callPackage ./pkgs/tkn {};
  toolbox = pkgs.callPackage ./pkgs/toolbox {};
  yaspell = pkgs.callPackage ./pkgs/yaspell {};

  # Upstream
  buildkit = pkgs.callPackage ./pkgs/buildkit {};
  containerd = pkgs.callPackage ./pkgs/containerd {};
  linuxkit = pkgs.callPackage ./pkgs/linuxkit {};
}
