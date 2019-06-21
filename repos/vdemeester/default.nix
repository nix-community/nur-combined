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
  knctl = pkgs.callPackage ./pkgs/knctl {};
  ko = pkgs.callPackage ./pkgs/ko {};
  krew = pkgs.callPackage ./pkgs/krew {};
  openshift-installer = pkgs.callPackage ./pkgs/openshift-installer {};
  operator-sdk = pkgs.callPackage ./pkgs/operator-sdk {};
  prm = pkgs.callPackage ./pkgs/prm {};
  protobuild = pkgs.callPackage ./pkgs/protobuild {};
  rmapi = pkgs.callPackage ./pkgs/rmapi {};
  s2i = pkgs.callPackage ./pkgs/s2i {};
  slirp4netns = pkgs.callPackage ./pkgs/slirp4netns {};
  # tilt = pkgs.callPackage ./pkgs/tilt {};
  tkn = pkgs.callPackage ./pkgs/tkn {};
  yaspell = pkgs.callPackage ./pkgs/yaspell {};

  # Upstream
  buildkit = pkgs.callPackage ./pkgs/buildkit {};
  cni = pkgs.callPackage ./pkgs/cni {};
  cni-plugins = pkgs.callPackage ./pkgs/cni/plugins.nix {};
  conmon = pkgs.callPackage ./pkgs/podman/conmon.nix {};
  containerd = pkgs.callPackage ./pkgs/containerd {};
  linuxkit = pkgs.callPackage ./pkgs/linuxkit {};
  minikube = pkgs.callPackage ./pkgs/minikube {};
  podman = pkgs.callPackage ./pkgs/podman {};
  runc = pkgs.callPackage ./pkgs/runc {};
}
