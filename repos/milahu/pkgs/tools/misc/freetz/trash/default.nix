{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, autoconf
, automake
, remake # gnumake + debug https://elinux.org/Debugging_Makefiles
# see also
# use 'command -v' instead of 'which'
# https://github.com/Freetz-NG/freetz-ng/pull/775
, which
, wget # TODO remove
, bison
, flex
, gettext
, git
, libtool
, perl
, pkg-config
, subversion
, unzip
, ncurses
, zlib
, libcap
, acl
, linux_6_2
}:

stdenv.mkDerivation rec {
  pname = "freetz";
  version = "23030";

  src = fetchFromGitHub {
    owner = "Freetz-NG";
    repo = "freetz-ng";
    rev = "ng${version}";
    hash = "sha256-Uw42TYDq4XXmxYOqB0iWCeRyylkQDG0R4EK64vjiD8U=";
  };

  hardeningDisable = [
    # fix build of busybox
    # archival/libarchive/decompress_lunzip.c:475:38: error: format not a string literal and no format arguments
    "format"
  ];

  linuxTarball = linux_6_2.src;

  # "kconfig" is a sparse checkout of linux
  # -> unpack faster
  kconfigTarball = let
    version = "6.2";
    rev = "c057e14f69c008200e5b9f22483426b53eaa37be";
  in
  # https://github.com/Freetz-NG/dl-mirror/raw/c057e14f69c008200e5b9f22483426b53eaa37be/kconfig-v6.2.tar.xz
  builtins.fetchurl {
    url = "https://github.com/Freetz-NG/dl-mirror/raw/${rev}/kconfig-v${version}.tar.xz";
    sha256 = "sha256-MgZrNLMRWITEC2KSl2uJiQYX9ByFYhPLgiMZv2oJfuo=";
  };

  patches = [
    ./fix-build.patch
  ];

  #VER = version;
  RH = version; # override default "UNKNOWN"

  preBuild = ''
    # TODO patch only some scripts? for example in tools/
    # TODO restore output = remove ">/dev/null"
    # many files -> verbose output
    echo patching shebangs
    patchShebangs . >/dev/null

    export HOME=$TMP

    # use bash from $PATH
    # TODO fix upstream
    substituteInPlace Makefile \
      --replace 'SHELL:=/bin/bash' "SHELL:=bash"

    #  --replace 'SHELL:=/bin/bash' "SHELL:=$(which bash)"

    if false; then

      # bug in remake? [probably not]
      # uname -r = 5.15.94
      # -> 5 != 3
      # FIXME Your Linux System is very old. Please upgrade it or use Freetz-Linux: https://github.com/Freetz-NG/freetz-ng/blob/master/README.md
      set -x
      uname -r
      uname -r | sed 's/\..*//;s/^[1-3]//'
      set +x

      set -x # debug

      pwd
      ls

      export TOOLS_SOURCE_DIR=$(pwd)/source/host-tools
      mkdir -p $TOOLS_SOURCE_DIR

      # parse linux abi version
      # example: $(call TOOLS_INIT, v6.2)
      # -> linuxAbiVersion=6.2
      linuxAbiVersion=$(cat make/host-tools/kconfig-host/kconfig-host.mk | head -n1 | sed -E 's/^.* v([0-9]+\.[0-9]+)\)$/\1/')
      echo parsed linux abi version: $linuxAbiVersion

      if false; then
        # FIXME error: building ... make[2]: *** No rule to make target 'menuconfig'.  Stop.
        # use kconfig tarball: fast unpack
        # check linux abi version
        if ! echo $kconfigTarball | grep -q -w -F "kconfig-v$linuxAbiVersion.tar"; then
          echo error: wrong version of kconfigTarball
          echo actual kconfigTarball: $kconfigTarball
          echo expected substring: kconfig-v$linuxAbiVersion.tar
          echo please fix this freetz.nix file
          exit 1
        fi
        echo creating tools/kconfig
        mkdir -p tools/kconfig
        tar xf $kconfigTarball -C tools/kconfig --strip-components=1
        ls -A tools/kconfig

        echo creating $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
        tar xf $kconfigTarball -C $TOOLS_SOURCE_DIR
        ls -A $TOOLS_SOURCE_DIR
        ls -A $TOOLS_SOURCE_DIR/*
        stat $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
        find $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion -type f
      else
        # FIXME error: building ... make[2]: *** No rule to make target 'menuconfig'.  Stop.
        # use linux tarball: slow unpack
        # check linux abi version
        if ! echo $linuxTarball | grep -q -w -F "linux-$linuxAbiVersion.tar"; then
          echo error: wrong version of linuxTarball
          echo actual linuxTarball: $linuxTarball
          echo expected substring: linux-$linuxAbiVersion.tar
          echo please fix this freetz.nix file
          exit 1
        fi
        linux_files_dst=$TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
        mkdir -p $linux_files_dst
        if false; then
          # unpack only some files
          linux_files=$(cat make/host-tools/kconfig-host/kconfig-host.mk | grep -F '$(PKG)_SITE:=git_archive@git://repo.or.cz/linux.git,' | cut -d, -f2- | tr , '\n')
          linux_files=$(echo "$linux_files" | sed "s|^|linux-$linuxAbiVersion/|")
          echo unpacking linux files to $linux_files_dst:
          printf "  %s\n" $linux_files
          tar xf $linuxTarball -C $linux_files_dst --strip-components=1 $linux_files
          stat $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
          ls -A $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
        else
          # unpack all files
          echo unpacking linux to $linux_files_dst
          tar xf $linuxTarball -C $linux_files_dst --strip-components=1
          stat $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
          ls -A $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion
        fi
      fi

      set +x

      substituteInPlace make/host-tools/kconfig-host/kconfig-host.mk \
        --replace '$(TOOLS_SOURCE_DOWNLOAD)' ""

      # TODO does this run configure? so build can run "make menuconfig"
      #substituteInPlace make/host-tools/kconfig-host/kconfig-host.mk \
      #  --replace '$(TOOLS_UNPACKED)' ""

      set -x

      touch $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion/.unpacked
      chmod -w $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion/.unpacked
      stat $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion/.unpacked
      # TODO why is our .unpacked file not found by make?
      set +x
      substituteInPlace make/host-tools/kconfig-host/kconfig-host.mk \
        --replace ' $($(PKG)_DIR)/.unpacked' ""
      set -x

      # FIXME error: building ... make[2]: *** No rule to make target 'menuconfig'.  Stop.
      # this works... but fails in freetz-ng/make/kernel/kernel.mk
      #make -C $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion menuconfig

      set +x
      patchShebangs $TOOLS_SOURCE_DIR/kconfig-v$linuxAbiVersion >/dev/null
    fi

    set -x
  '';

  makeFlags = [
    "RH=${version}" # override default version "UNKNOWN"
    "-d" # debug
  ];

  # debug
  /*
  buildPhase = ''
    runHook preBuild
    remake --trace "''${makeFlagsArray[@]}"
    runHook postBuild
  '';
  */

  buildInputs = [
    autoconf # autoreconf
    automake
    remake
    which
    wget # TODO remove
    bison
    flex
    gettext
    git
    libtool
    perl
    pkg-config
    subversion # svn
    unzip
    /*
ERROR: The header file 'ncurses.h' was not found in /usr/(local/)include
ERROR: The header file 'zlib.h' was not found in /usr/(local/)include
ERROR: The header file 'sys/acl.h' was not found in /usr/(local/)include
ERROR: The header file 'sys/capability.h' was not found in /usr/(local/)include
    */
    ncurses
    zlib
    libcap # sys/capability.h
    acl # sys/acl.h
  ];

  meta = with lib; {
    description = "firmware modification for AVM devices like FRITZ!Box";
    homepage = "https://github.com/Freetz-NG/freetz-ng";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
  };
}
