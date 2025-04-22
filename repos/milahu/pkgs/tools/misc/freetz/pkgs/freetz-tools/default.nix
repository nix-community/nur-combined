{ lib
, stdenvNoCC
, fetchFromGitHub
, fetchurl
, makeWrapper
, freetz
# TODO restore?
#, visualise-make
, lndir
, kconfig
, gnutar
, busybox
, wget
, gzip
, lunzip
, automake
, autoconf
, libpkgconf
, gnumake
, cmakeCurses
, ninja
, patchelf
, pkg-config
, pkgconf
, gnum4
, libtool
, pseudo
, mpfr
, libmpc
, gmp
, dtc
, prelink
, tichksum
, lzma2eva
, find-squashfs
, swissfileknife
, squashfs-tools-avm-le
, squashfs-tools-avm-be
, yf-akcarea
, perl
, perlPackages
, graphviz
}:

stdenvNoCC.mkDerivation rec {
  pname = "freetz-tools";
  inherit (freetz) version meta;

  buildCommand = ''
    mkdir -p $out/opt/freetz

    # add scripts
    cp -r ${freetz.src}/tools $out/opt/freetz/tools
    cd $out/opt/freetz/tools
    chmod -R +w .
    rm visualise_make.pl
    ${""/*
    TODO restore?
    ln -s ${visualise-make}/bin/visualise_make.pl .
    */}
    chmod +x freetz_bin_functions
    chmod +x freetz_functions
    chmod +x freetz_mklibs
    patchShebangs .

    # add binaries
    ln -s ${gnutar}/bin/tar tar-gnu
    ln -s ${busybox}/bin/{busybox,ash,blkid,bunzip2,gunzip,crc32,md5sum,makedevs,sed,sha1sum,sha256sum,sha512sum,sum,tar,unlzma,unxz,unzip,xargs,xz} .
    ln -s ${gzip}/bin/uncompress .
    #ln -s ${squashfs-tools-avm-le}/bin/*squashfs4* .
    #ln -s ${squashfs-tools-avm-be}/bin/*squashfs4* .
    ${builtins.concatStringsSep "\n" (builtins.map (pkg: ''
      ln -s ${pkg}/bin/* .
    '') [
      tichksum
      lzma2eva
      find-squashfs
      swissfileknife
      squashfs-tools-avm-le
      squashfs-tools-avm-be
      prelink
      ninja
      patchelf
      yf-akcarea
      lunzip
    ])}

    pushd path
    ln -s ${busybox}/bin/{cpio,gunzip,gzip} .
    ln -s ${wget}/bin/* .
    popd

    mkdir build
    pushd build
    ${builtins.concatStringsSep "\n" (builtins.map (pkg: ''
      ${lndir}/bin/lndir -silent ${pkg} .
    '') [
      automake
      autoconf
      cmakeCurses
      gnumake
      pkg-config
      libpkgconf
      libpkgconf.lib
      libpkgconf.dev
      gnum4
      libtool
      libtool.lib
      pseudo
      mpfr
      mpfr.dev
      libmpc
      gmp
      gmp.dev
      dtc
    ])}
    popd

    mkdir kconfig
    pushd kconfig
    ln -s ${kconfig}/bin/* .
    popd
  '';
}
