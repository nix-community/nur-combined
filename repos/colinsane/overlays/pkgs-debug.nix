(final: prev:
let
  # bootstrapPnames = [
  #   # this probably doesn't actually accomplish anything:
  #   # so long as a *single* input to e.g. gcc is omitted from here, then gcc gets recompiled -- even if gcc is in this list.
  #   #   and then everything which uses gcc also gets recompiled.
  #   #   gcc has like 200 derivations in its closure -- incl glibc, which we'd like debug symbols for! -- so that's gonna happen one way or another.
  #   "autoconf"
  #   "automake"
  #   "bash"
  #   "binutils"
  #   "binutils-wrapper"
  #   "bison"
  #   "bzip2"
  #   "cmake-minimal"
  #   "coreutils"
  #   "diffutils"
  #   "docbook-xml"
  #   "ed"
  #   "expect"
  #   "file"
  #   "findutils"
  #   "gcc"
  #   "gcc-wrapper"
  #   "gettext"
  #   "gmp"
  #   "gnugrep"
  #   "gnum4"
  #   "gnused"
  #   "gzip"
  #   "libidn2"
  #   "libtool"
  #   "libunistring"
  #   "libxcrypt"
  #   "linux-headers"
  #   "meson"
  #   "patch"
  #   "patchelf"
  #   "perl"
  #   "pkg-config"
  #   "python3-minimal"
  #   "stdenv-linux"
  #   "texinfo"
  #   "which"
  #   "xgcc"
  #   "xz"
  #   "zlib"
  #   # "acl"
  #   # "attr"
  #   # "expat"
  #   # "glibc"
  #   # "libffi"
  #   # "mpdecimal"

  #   "unknown"
  # ];
  # doEnableDebug = pname: !(prev.lib.elem pname bootstrapPnames);
  dontDebug = [
    "libgcrypt"  #< very picky about its compiler flags (wants -O0, nothing else)
    "python3"
    "systemd"  #< fails to compile with -fsanitize=undefined
    "systemd-minimal" "systemd-minimal-libs"
    "valgrind"  #< need the perf benefit

    # just to speed things up
    # "appstream"
    "bash" "bash-completion" "bash-interactive"
    # "bluez"
    "brotli"
    "bzip2"
    "cups"
    "e2fsprogs"
    "elfutils"
    "ffmpeg" "openal-soft" "pipewire" #< slow to compile
    "gcc" "gfortran"
    # "flite"
    # "gspell"
    "kexec-tools"
    "kmod"
    "libarchive"
    "libqmi" "modemmanager" "networkmanager"  #< libqmi is SLOW to compile
    "libtool"
    "libusb"
    "linux-headers"
    "linux-pam"
    # "pcre2"
    "perl"
    "readline"
    "sharutils"
    "serd"
    "sord"
    "sqlite"
    "tracker"
    "util-linux" "util-linux-minimal"
    "vala"
    "wayland"
    "xapian"
    "xz"
    "zlib"
    "zstd"
  ];
in
{
  enableDebugging = pkg: pkg.overrideAttrs (args: args // {
    # see also: <https://wiki.nixos.org/wiki/Debug_Symbols>
    dontStrip = true;
    separateDebugInfo = false;
    # -Wno-error: because enabling debug sometimes causes gcc to catch more errors
    env = (args.env or {}) // {
      NIX_CFLAGS_COMPILE = prev.lib.concatStringsSep " " ([
        (toString (args.env.NIX_CFLAGS_COMPILE or ""))
        "-ggdb"
        "-Og"
        "-fno-omit-frame-pointer"
        "-Wno-error"
        # "-fhardened"
        # "-fcf-protection=full"  # x86-only
        # "-fsanitize=undefined"
        # "-fsanitize=address"  # syntax errors, unable to load `libstdc++.so`
        # "-fsanitize=hwaddress"  # undefined reference to __hwasan_init, syntax errors, unable to load `libstdc++.so`
        # "-fsanitize=thread"
        # "-fsanitize-trap=all"
      ] ++ prev.lib.optionals (args.pname or args.name or "" != "glibc") [
        "-fstack-protector-strong"  # doesn't compile for glibc
      ]);
      # ASAN_OPTIONS = "detect_leaks=false";
      # MSAN_OPTIONS = "detect_leaks=false";
      # HWASAN_OPTIONS = "detect_leaks=false";
    };
    cargoBuildType = args.cargoBuildType or "debug";
    cmakeBuildType = args.cmakeBuildType or "RelWithDebInfo";  # Debug, or RelWithDebInfo
    mesonBuildType = args.mesonBuildType or "debugoptimized";
    # TODO: ensure `NDEBUG` is removed from any make/cmake/etc flags
  });
  tryEnableDebugging' = enabler: pkg:
    if prev.lib.isAttrs pkg && pkg ? overrideAttrs && !(prev.lib.elem (pkg.pname or "") dontDebug) then
      enabler pkg
    else
      pkg;
  tryEnableDebugging = final.tryEnableDebugging' final.enableDebugging;
  enableDebuggingInclDependencies = pkg: (final.enableDebugging pkg).overrideAttrs (args: args // {
    buildInputs = builtins.map final.tryEnableDebuggingInclDependencies (args.buildInputs or []);
  });
  tryEnableDebuggingInclDependencies = final.tryEnableDebugging' final.enableDebuggingInclDependencies;
  pkgsDebug = prev.lib.mapAttrs (_pname: final.tryEnableDebuggingInclDependencies) final;
})
