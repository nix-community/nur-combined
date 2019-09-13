{ nixpkgs ? <nixpkgs>, allvm ? <allvm> }:

let
  pkgs  = import nixpkgs {};
  allvmPkgs = import <allvm> {};
in rec {
  nuked = pkgs.runCommandNoCC "nuke" {
    nativeBuildInputs = with pkgs; [ nukeReferences findutils ];
  } ''

    cp -a ${allvmPkgs.nix-mux} $out

    chmod u+w -R $out

    find $out -type f -print0 | xargs -0 nuke-refs
  '';

  package = pkgs.runCommandNoCC "nix.tar.xz" {} ''
    # TODO: well if we need to make a copy,
    # might as well do nuke here while we're at it
    cp -a ${nuked} copy
    chmod u+w -R copy

    mkdir -p copy/etc/ssl/certs
    cp ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ./copy/etc/ssl/certs/

    XZ_OPT="-9 -e" ${pkgs.gnutar}/bin/tar cvJf $out --hard-dereference --sort=name --numeric-owner --owner=0 --group=0 --mtime=@1 -C ./copy .
  '';

  # TODO: better way of grabbing this
  busybox = pkgs.stdenv.bootstrapTools.builder;

  ###################################################

  bootstrapFiles = {
    # Make them their own store paths to test that busybox still works when the binary is named /nix/store/HASH-busybox
    busybox = pkgs.runCommandNoCC "busybox" {} "cp ${busybox} $out";
    tarball = pkgs.runCommandNoCC "nix.tar.xz" {} "cp ${package} $out";
  };

  #unpack = import ./unpack.nix {
  #  inherit (pkgs.hostPlatform) system;
  #  inherit bootstrapFiles;
  #};

 # test = derivation = {
 #   name = "test-nix-mux";
 #   inherit (pkgs.hostPlatform) system;
 #   builder = 
}
