{
  ### Tools
  stdenv,
  buildFHSEnv,
  lib,
  libsForQt5,
  clang,
  lld,
  llvm,
  zlib,
  elfutils,
  pkgs,
  ncurses,
  bashInteractive,
  writeScript,
  inetutils,
  ### Options
  kernel-tools ? false,
  # Option to enable kernel development tools
  buildroot-tools ? false,
  # Option to enable Buildroot-specific tools
  useClang ? false,
  # Enable this to use clang instead of gcc
  debian-tools ? false,
  # Add debian tools (to prepare debian package)
  redhat-tools ? false, # Add fedora and RHEL (and clone) tools (same as debian-tools option)

  ### Extra packages to include in the FHS environment
  ### Can be a list `[ pkgs.hello ]` or a function `pkgs: [ pkgs.hello ]`
  extraPkgs ? [ ],
  ### Extra shell commands to run at environment startup (before the prompt is set)
  extraInitCommands ? "",

  ### Extra bwrap arguments (list of strings) passed directly to bubblewrap
  ### e.g. [ "--bind" "/tmp/cache" "/var/cache" ] to mount writable tmpfs
  extraBwrapArgs ? [ ],
}:

let
  ### System configuration (host platform)
  system = lib.systems.elaborate stdenv.hostPlatform;

  ### debhelper from Debian (dh_*, dh — needed by kernel's deb-pkg/rules)
  debhelperPackage =
    let
      dv = "13.14.1ubuntu5";
    in
    pkgs.runCommand "dh-${dv}"
      {
        nativeBuildInputs = [ pkgs.dpkg ];
      }
      ''
        mkdir -p out
        dpkg-deb -x ${
          pkgs.fetchurl {
            url = "http://security.ubuntu.com/ubuntu/pool/main/d/debhelper/debhelper_${dv}_all.deb";
            hash = "sha256-dX12KxKvHk1ZTqjCAMCjJ1Ueg89+jMdh25VUXj3sjVY=";
          }
        } out
        dpkg-deb -x ${
          pkgs.fetchurl {
            url = "http://security.ubuntu.com/ubuntu/pool/main/d/debhelper/libdebhelper-perl_${dv}_all.deb";
            hash = "sha256-F44uHFhfaYCljf4BkAQ/OY6we6vjNtjcH86sJ6eHuuM=";
          }
        } out
        mkdir -p $out/bin
        for f in out/usr/bin/*; do
          [ -f "$f" ] && cp "$f" "$out/bin/"
        done
        if [ -d out/usr/share/perl5 ]; then
          mkdir -p $out/lib/perl5
          cp -r out/usr/share/perl5/* $out/lib/perl5/
        fi
        rm -rf out
      '';
in
if kernel-tools && !(system.isx86 or false) then
  throw ''
    fhsEnv-shell: kernel-tools boot image targets (isoimage, hdimage, fdimage, bzdisk)
    are x86-only. Use extraPkgs to add custom ISO/image creation tools on non-x86
    platforms. (kernel compilation and deb/rpm packaging still work on all archs.)
  ''
else
  stdenv.mkDerivation rec {
    pname = "fhsEnv-shell";
    version = "1.5.0";

    ### stdenv options
    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;
    dontPatchElf = true;

    ### fhsEnv software
    fhsEnv = buildFHSEnv {
      name = "fhsEnv-shell";
      targetPkgs =
        pkgs:
        with pkgs;
        [
          ### Core compilation tools (always included)
          # Compiler and tools
          # use clang.cc (unwrapped) when kernel-tools + useClang to avoid nixpkgs wrapper
          # injecting NIX_CFLAGS_COMPILE which conflicts with kernel's -nostdlibinc
          (if useClang then (if kernel-tools then clang.cc else clang) else stdenv.cc)
          pkg-config
          # Use clang instead of gcc
          # make wrapper: kernel Makefile overrides CC=gcc (line 535),
          # env var isn't enough — force CC=clang as command-line arg
          (
            if useClang then
              pkgs.writeShellScriptBin "make" ''
                exec ${gnumake}/bin/make CC=clang "$@"
              ''
            else
              gnumake
          )
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
            export PATH=${lib.getBin inetutils}
            exec -a "$0" ${inetutils}/bin/ftp "$@"
          '')

          ### Programming language
          python3
          perl
          ncurses5 # For Text User Interface

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
        ]
        ++ lib.optionals useClang (
          [
            clang-manpages

            ### LLVM toolchain (linker, archiver, objcopy, etc.)
            lld
            llvm
          ]
          # include gcc for host tools (fixdep, etc.) that need proper include paths
          ++ lib.optionals kernel-tools [ stdenv.cc ]
        )
        ++ lib.optionals kernel-tools (
          [
            ### Kernel-specific tools (enabled with kernel-tools = true)
            libsForQt5.qt5.qtbase
            libcap_ng
            pciutils

            ### Headers
            openssl.dev
            ncurses5.dev
            libsForQt5.qt5.qtbase.dev

            ### Iso tools
            syslinux
            (pkgs.writeShellScriptBin "genisoimage" ''
              # genisoimage -boot-info-table modifies the boot file in-place
              # but cp preserves nix store read-only permissions
              # → make the source directory writable first
              sourcedir="''${@: -1}"
              [ -d "$sourcedir" ] && chmod -R u+w "$sourcedir" 2>/dev/null || true
              exec ${pkgs.cdrkit}/bin/genisoimage "$@"
            '')
          ]
          ++ pkgs.linux.nativeBuildInputs
        )
        ++ lib.optionals buildroot-tools ([
          # Buildroot-specific tools
          flex
          bison
          gawk
          texinfo

          # Buildroot extra dependencies
          patchutils
          swig
          gperf
          libtool
          libmpc
          libelf
          mpfr
          gmp
        ])
        ++ lib.optionals debian-tools ([
          # wrapper must come before dpkg to take precedence in /bin
          # -d skips build-dependency checks (no real dpkg database in FHS env)
          # --admindir redirects to a writable path (FHS env /var is read-only)
          (pkgs.writeShellScriptBin "dpkg-buildpackage" ''
            DPKG_ADMINDIR="''${DPKG_ADMINDIR:-$HOME/.cache/fhsEnv/dpkg}"
            exec ${dpkg}/bin/dpkg-buildpackage -d --admindir="$DPKG_ADMINDIR" "$@"
          '')
          dpkg
          lsb-release
          glibc.dev
          debhelperPackage
        ])

        ++ lib.optionals redhat-tools ([
          # rpm for RedHat-family packaging
          rpm
        ])
        ++ (if builtins.isFunction extraPkgs then extraPkgs pkgs else extraPkgs);

      ### Shell script that runs automatically when entering this environment
      runScript = pkgs.writeScript "init.sh" ''
        ### Environment variables
        export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$HOME/bin:$HOME/.local/bin
        export TERM=xterm-256color
        export ARCH=${lib.head (lib.splitString "-" system.config)}
        export hardeningDisable=all

        ### Variable used for compilation
        export CC="${if useClang then "clang" else "gcc"}"
        export CXX="${if useClang then "clang++" else "g++"}"
        ${lib.optionalString useClang ''
          ### LLVM/Clang toolchain for kernel builds
          ### Use individual vars instead of LLVM=1 because LLVM=1 overrides
          ### HOSTCC=clang in the kernel Makefile, breaking host tools (fixdep, etc.)
          ### that need gcc's include paths. Pass CC=clang + individual LLVM vars
          ### instead of the LLVM=1 shorthand. HOSTCC defaults to gcc (stdenv.cc).
          export CC=clang
          export CXX=clang++
          export LD=ld.lld
          export AR=llvm-ar
          export NM=llvm-nm
          export OBJCOPY=llvm-objcopy
          export OBJDUMP=llvm-objdump
          export STRIP=llvm-strip
        ''}

        ${lib.optionalString kernel-tools ''
          ### Special flags for kernel build (explicit path)
          export QT_QPA_PLATFORM_PLUGIN_PATH="${libsForQt5.qt5.qtbase.bin}/lib/qt-${libsForQt5.qt5.qtbase.version}/plugins"

          export PKG_CONFIG_PATH="${ncurses.dev}/lib/pkgconfig:${libsForQt5.qt5.qtbase.dev}/lib/pkgconfig:${zlib.dev}/lib/pkgconfig:${elfutils.dev}/lib/pkgconfig"

          export LD_LIBRARY_PATH="${zlib.out}/lib:${elfutils.out}/lib:$LD_LIBRARY_PATH"
          export LIBRARY_PATH="${zlib.out}/lib:${elfutils.out}/lib:$LIBRARY_PATH"
          export CFLAGS="-I${zlib.dev}/include -I${elfutils.dev}/include $CFLAGS"
          export LDFLAGS="-L${zlib.out}/lib -L${elfutils.out}/lib -lelf -lz $LDFLAGS"

        ''}
        ${lib.optionalString (debian-tools || kernel-tools) ''
          # kernel-tools enables make deb-pkg/make bindeb-pkg which call dpkg-buildpackage
          # internally even without debian-tools enabled
          # dpkg needs /var/lib/dpkg/status but /var is read-only in FHS env
          # → redirect to a writable path via DPKG_ADMINDIR
          export DPKG_ADMINDIR="$HOME/.cache/fhsEnv/dpkg"
          mkdir -p "$DPKG_ADMINDIR"
          if [ ! -f "$DPKG_ADMINDIR/status" ]; then
            touch "$DPKG_ADMINDIR/status"
          fi
        ''}
        ${lib.optionalString debian-tools ''
          # nixpkgs lsb_release -cs may return a quoted codename (e.g. "yarara" on NixOS)
          # which breaks debian/changelog format — force a clean distribution name
          export KDEB_CHANGELOG_DIST=unstable
          # Perl modules for dpkg (Dpkg::Arch, etc.) and debhelper (Debian::Debhelper::Dh_Lib, etc.)
          export PERL5LIB="${pkgs.dpkg}/lib/perl5/site_perl:${debhelperPackage}/lib/perl5''${PERL5LIB:+:$PERL5LIB}"
        ''}
        ${lib.optionalString redhat-tools ''
          # rpmbuild needs /var/lib/rpm which is read-only in FHS env
          # → redirect via %_dbpath macro in ~/.rpmmacros
          export RPMDB_DIR="$HOME/.cache/fhsEnv/rpm"
          mkdir -p "$RPMDB_DIR"
          echo '%_dbpath '"$RPMDB_DIR" > "$HOME/.rpmmacros"
          if ! rpm --dbpath "$RPMDB_DIR" -qa >/dev/null 2>&1; then
            rpm --dbpath "$RPMDB_DIR" --initdb 2>/dev/null || true
          fi
        ''}
        ${lib.optionalString (extraInitCommands != "") ''
          ### User-defined init commands
          ${extraInitCommands}
        ''}
        ### Custom PS1 for the shell environment (NixOS style)
        export PROMPT_COMMAND='PS1="\[\e[1;32m\][fhsEnv-shell:\w]\$\[\e[0m\] "'

        ### Exec bash from Nixpkgs/NixOS
        exec ${bashInteractive}/bin/bash
      '';
      inherit extraBwrapArgs;
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
      platforms = lib.platforms.linux;
    };
  }
