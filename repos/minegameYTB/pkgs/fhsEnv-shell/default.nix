{
 stdenvNoCC,
 buildFHSEnv,
 lib,
 libsForQt5,
 zlib,
 elfutils,
 pkgs,
 gcc,
 ncurses,
 bashInteractive,
 writeScript,
 kernel-tools ? false,  ### Option to enable kernel development tools
 buildroot-tools ? false,  ### Option to enable Buildroot-specific tools
 useClang ? false, ### Enable this to use clang instead of gcc
 debian-tools ? false, ### Add debian tools (to prepare debian package)
 redhat-tools ? false  ### Add fedora and RHEL (and clone) tools (same as debian-tools option)
}:

let
  ### System configuration (host platform)
  system = lib.systems.elaborate stdenvNoCC.hostPlatform;

  fhsEnv = buildFHSEnv {
    name = "fhsEnv-shell";
    targetPkgs = pkgs: with pkgs; [
      ### Core compilation tools (always included)
      ### Compiler and tools
      (if useClang then clang else gcc)
      pkg-config
      gnumake
      gnupatch

      ### Coreutils
      coreutils-full
      kmod
      nettools
      man 
      which
      procps
      iputils
      file
      findutils
      util-linux
      bc
      man
      lsd
      bat

      ### Text editor
      nano
      vim

      ### Version manager
      git
      subversion
      
      ### Archive
      gnutar
      gzip
      bzip2
      xz
      cpio
      unzip
      lz4

      ### Network and cryptography
      rsync
      wget
      wget2 ### In case of wget is aliases to wget2
      openssl

      ### Programming language
      python3
      perl
      ncurses5 ### For Text User Interface

      ### Additional essential tools for compatibility
      flex
      bison
      gawk
      gettext
      texinfo
      gnum4

      ### Additional package
      autoconf
      automake
    ] ++ lib.optionals useClang ([
      clang-manpages
    ]) ++ lib.optionals kernel-tools ([
      ### Kernel-specific tools (enabled with kernel-tools = true)
      libsForQt5.qt5.qtbase
      libcap_ng
      pciutils

      ### Rust tools
      rustc
      rust-bindgen
      
      ### Headers
      openssl.dev
      ncurses5.dev
      libsForQt5.qt5.qtbase.dev

      ### Iso tools
      syslinux
      cdrkit
    ] ++ pkgs.linux.nativeBuildInputs) ++ lib.optionals buildroot-tools ([
      ### Buildroot-specific tools (enabled with buildroot-tools = true) 
      ### When kernel-tools is not used, include these tools in case
      flex
      bison
      gawk
      gettext
      texinfo

      ### Buildroot dependancies in additions to other tools
      patchutils
      swig
      gperf
      libtool
      libmpc
      libelf
      mpfr
      gmp
    ]) ++ lib.optionals debian-tools ([
      ### Debian package
      dpkg
      apt
      
      ### Use glibc.dev to match with build-essential package on debian
      glibc.dev
    ]) ++ lib.optionals redhat-tools ([
      ### RedHat package
      rpm
      dnf5
    ]);

    ### Shell script that run automacally when enterred in this environment
    runScript = pkgs.writeScript "init.sh" ''
      ### Environment variables
      export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$HOME/bin:$HOME/.local/bin
      export TERM=xterm-256color
      export ARCH=${lib.head (lib.splitString "-" system.config)}
      export hardeningDisable=all

      ### Variable used for compilation
      export CC="${if useClang then "clang" else "gcc"}"
      export CXX="${if useClang then "clang++" else "g++"}"

      ${lib.optionalString kernel-tools ''
        ### Special flags for kernel build (explicit path)
        export QT_QPA_PLATFORM_PLUGIN_PATH="${libsForQt5.qt5.qtbase.bin}/lib/qt-${libsForQt5.qt5.qtbase.version}/plugins"

        export PKG_CONFIG_PATH="${ncurses.dev}/lib/pkgconfig:${libsForQt5.qt5.qtbase.dev}/lib/pkgconfig:${zlib.dev}/lib/pkgconfig:${elfutils.dev}/lib/pkgconfig"

        export LD_LIBRARY_PATH="${zlib.out}/lib:${elfutils.out}/lib:$LD_LIBRARY_PATH"
        export LIBRARY_PATH="${zlib.out}/lib:${elfutils.out}/lib:$LIBRARY_PATH"
        export CFLAGS="-I${zlib.dev}/include -I${elfutils.dev}/include $CFLAGS"
        export LDFLAGS="-L${zlib.out}/lib -L${elfutils.out}/lib -lelf -lz $LDFLAGS"
      ''}
      ### Custom PS1 for the shell environment (NixOS style)
      export PROMPT_COMMAND='PS1="\[\e[1;32m\][fhsEnv-shell:\w]\$\[\e[0m\] "'

      exec ${bashInteractive}/bin/bash
    '';
  };
in stdenvNoCC.mkDerivation {
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
    description = "A multi-platform, multi-distribution development environment for Linux kernel and Buildroot tooling.";
    license = licenses.gpl3;
    mainProgram = "fhsEnv-shell";
  };
}
