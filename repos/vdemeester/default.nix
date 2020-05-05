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
  prm = pkgs.callPackage ./pkgs/prm {};
  protobuild = pkgs.callPackage ./pkgs/protobuild {};
  rmapi = pkgs.callPackage ./pkgs/rmapi {};
  toolbox = pkgs.callPackage ./pkgs/toolbox {};
  yaspell = pkgs.callPackage ./pkgs/yaspell {};

  # OpenShift
  inherit (pkgs.callPackage ./pkgs/oc {})
    oc_4_1
    oc_4_2
    oc_4_3
    oc_4_4
    ;
  oc = oc_4_4;
  openshift-install = pkgs.callPackage ./pkgs/openshift-install {};

  inherit (pkgs.callPackage ./pkgs/crc {})
    crc_1_9
    crc_1_10
    ;
  crc = crc_1_10;

  # Operator SDK
  operator-sdk = pkgs.callPackage ./pkgs/operator-sdk {};

  # Tekton
  inherit (pkgs.callPackage ./pkgs/tkn {})
    tkn_0_8
    tkn_0_9
    ;
  tkn = tkn_0_9;

  # Upstream
  buildkit = pkgs.callPackage ./pkgs/buildkit {};
  inherit (pkgs.callPackage ./pkgs/containerd {})
    containerd_1_2
    containerd_1_3
    ;
  containerd = containerd_1_3;
}
