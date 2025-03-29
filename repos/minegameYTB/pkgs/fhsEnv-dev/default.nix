{
 stdenvNoCC,
 stdenv,
 buildFHSEnv,
 lib,
 libsForQt5,
 pkgs,
 gcc,
 ncurses,
 writeScript,
 kernel-tools ? false,
 useClang ? false
}:

let
  # Sélection du stdenv en fonction du choix du compilateur
  stdenv = if useClang then pkgs.clangStdenv else pkgs.stdenv;

  # Configuration système automatique
  system = lib.systems.elaborate stdenv.hostPlatform;

  fhsEnv = buildFHSEnv {
    name = "fhsEnv-shell";
    targetPkgs = pkgs: with pkgs; [
      nettools
      ncurses5
      (if useClang then clang else gcc)
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
      libxcrypt
      libtool
      libmpc
      libelf
      ncurses5.dev
      libsForQt5.qt5.qtbase
    ] ++ lib.optionals kernel-tools ([
      kmod
      elfutils
      libcap
      libcap_ng
      xorg.libpciaccess
      pciutils
      usbutils
      udev
      zlib
      dpkg
      openssl.dev
      zstd
      rustc
      rust-bindgen
      pahole
    ] ++ pkgs.linux.nativeBuildInputs);

    runScript = pkgs.writeScript "init.sh" ''
      echo "Entering fhsEnv-shell environment"
      export ARCH=${lib.head (lib.splitString "-" system.config)}
      export hardeningDisable=all
      export CC="${if useClang then "clang" else "gcc"}"
      export CXX="${if useClang then "clang++" else "g++"}"
      export PKG_CONFIG_PATH="${ncurses.dev}/lib/pkgconfig:${libsForQt5.qt5.qtbase.dev}/lib/pkgconfig"
      export QT_QPA_PLATFORM_PLUGIN_PATH="${libsForQt5.qt5.qtbase.bin}/lib/qt-${libsForQt5.qt5.qtbase.version}/plugins"

      ### Custom PS1
      export PROMPT_COMMAND='PS1="\[\e[1;32m\][fhsEnv-shell:\w]:\$\[\e[0m\] "'

      exec bash
    '';
  };
in
stdenv.mkDerivation {
  pname = "fhsEnv-shell";
  version = gcc.version;

  ### stdenv options
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontPatchElf = true;

  installPhase = ''
    mkdir $out
    ln -s ${fhsEnv}/bin $out/bin
  '';

  meta = with lib; {
    description = "A build-essential like tool, but multi-distribution";
    license = licenses.gpl3;
    mainProgram = "fhsEnv-shell";
  };
}

