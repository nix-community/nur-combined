{
 ### Tools
 stdenv,
 buildFHSEnv,
 lib,
 libsForQt5,
 clang,
 zlib,
 elfutils,
 pkgs,
 ncurses,
 bashInteractive,
 writeScript,
 inetutils,

 ### Options
 kernel-tools ? false,  ### Option to enable kernel development tools
 buildroot-tools ? false,  ### Option to enable Buildroot-specific tools
 useClang ? false, ### Enable this to use clang instead of gcc
 debian-tools ? false, ### Add debian tools (to prepare debian package)
 redhat-tools ? false  ### Add fedora and RHEL (and clone) tools (same as debian-tools option)
}:

let
  ### System configuration (host platform)
  system = lib.systems.elaborate stdenv.hostPlatform;
in 
stdenv.mkDerivation rec {
  pname = "fhsEnv-shell";
  version = "1.1.0";

  ### stdenv options
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontPatchElf = true;
  
  ### fhsEnv software
  fhsEnv = buildFHSEnv {
    name = "fhsEnv-shell";
    targetPkgs = pkgs: with pkgs; [
      ### Core compilation tools (always included)
      ### Compiler and tools
      (if useClang then clang else stdenv.cc)
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
      cvs

      ### Archive
      gnutar
      gzip
      bzip2
      xz
      cpio
      unzip
      lz4
      zstd

      ### Network and cryptography
      rsync
      wget
      openssl
      # For ftp binary
      (pkgs.writeShellScriptBin "ftp" ''
        ### Use inetutils to use only the ftp command (eventually other tools with this function to isolate software)
        export PATH=${lib.getBin inetutils}
        exec -a "$0" ${inetutils}/bin/ftp "$@"
      '')

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
      zlib.dev

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
      #rustc
      #rust-bindgen
      
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
      
      ### Use glibc.dev to match with build-essential package on debian
      glibc.dev
    ]) ++ lib.optionals redhat-tools ([
      ### RedHat package
      rpm
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

      ### Exec bash from Nixpkgs/NixOS
      exec ${bashInteractive}/bin/bash
    '';
  };
  
  installPhase = ''
    mkdir $out
    ln -s ${fhsEnv}/bin $out/bin
  '';

  meta = {
    description = "A multi-platform, multi-distribution development environment for Linux kernel and Buildroot tooling.";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ minegameYTB ];
    mainProgram = "fhsEnv-shell";
  };
}
