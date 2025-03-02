{ stdenvNoCC, callPackage, buildFHSEnv, lib, gcc, xorg, kernel-tools ? false }:

let
  ### import libpci-dev from debian sid repo
  libpci-dev = callPackage ./libpci-dev.nix {};
  fhsEnv = buildFHSEnv {
    name = "fhsEnv";
    targetPkgs = pkgs: with pkgs; [    
      ### Base packages
      nettools
      ncurses5

      ### Build Dependency
      gcc
      gnumake
      patch
      git
      gnutar
      gzip
      bzip2
      xz
      rsync
      wget
      cpio
      perl
      python3
      which
      file
      findutils
      util-linux
      openssl
      bc
      unzip
      pkg-config
      flex
      bison
      gawk
      gettext
      texinfo
      patchutils
      swig
      gperf
      mpfr
      gmp
      
      ### Library and headers
      libxcrypt
      libtool
      libmpc
      libelf
      ncurses5.dev
    ] ++ lib.optionals kernel-tools [
      ### Additional tools if kernel-tools is true
      kmod
      elfutils
      elfutils.dev
      libcap
      libcap.dev
      libcap_ng
      libcap_ng.dev
      xorg.libpciaccess
      pciutils
      usbutils
      udev
      udev.dev
      zlib
      zlib.dev
      dpkg
      openssl.dev
      libpci-dev

      zstd
      rustc
      rust-bindgen
      pahole
    ];

    runScript = "bash";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "fhsEnv-shell";
  version = gcc.version;

  ### stdenv options
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontPatchElf = true;

  installPhase = ''
    ### Make fhsEnv-shell available
    mkdir -p $out/bin
    ln -s ${fhsEnv}/bin/fhsEnv $out/bin/fhsEnv-shell
  '';

  meta = with lib; {
    description = "A build-essential like tool, but multi-distribution";
    license = licenses.gpl3;
    mainProgram = "fhsEnv-shell";
  };
}
