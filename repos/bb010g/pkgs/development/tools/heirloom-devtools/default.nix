{ stdenv, fetchurl, runCommand, writeText
, bash, heirloom-sh
, llvmPackages ? null
, shell ? "${heirloom-sh}/bin/sh", posixShell ? "${bash}/bin/sh"
, enableAsan ? false /* !enableMsan */, asanDefaultOpts ? "detect_leaks=false"
, enableFramePointer ? enableMsan
, enableMsan ? false /* stdenv.cc.isClang or false */
, enableMsanTrackOrigins ? true
, enablePIE ? enableMsan
}:

assert enableMsan -> enablePIE;
assert enableAsan -> !enableMsan;
assert enableMsan -> !enableAsan;

let
  inherit (stdenv) lib;
  sh = lib.escapeShellArg;
  inherit (stdenv.cc) isClang;
  asanDefaultOptsC = writeText "asan-default-options.c" ''
    #include <sanitizer/asan_interface.h>

    #ifdef __cplusplus
    extern "C" {
    extern const char *__asan_default_options() {
    #else
    extern const char *__asan_default_options(void) {
    #endif
	    return ASAN_DEFAULT_OPTIONS;
    }
    #ifdef __cplusplus
    }
    #endif
  '';
in stdenv.mkDerivation rec {
  pname = "heirloom-devtools";
  version = "070527";

  src = fetchurl {
    url = "mirror://sourceforge/heirloom/${pname}/${version}/${pname}-${version}.tar.bz2";
    sha256 = "1flihq2qx82q2i91i62fylvazrd0b0wxhl1dvpliydg4g25ks8wz";
  };
  # Includes patches from Adélie Linux's Adélie Package Tree.
  # https://code.foxkit.us/adelie/packages/tree/master/system/heirloom-devtools
  patches = [
    ./deauto.patch # (Adélie)
    ./64-bit.patch # (Adélie)
    ./relative-symbolic-links.patch
    ./format-security.patch
    ./pass-san.patch
    ./linux-no-stropts.patch
  ];

  outputs = [ "out" "lib" "man" ];

  propagatedBuildInputs = [
  ] ++ lib.optionals (enableMsan && isClang && llvmPackages != null) [
    # for msan failure traces
    (runCommand "llvm-symbolizer"
      { preferLocalBuild = true; allowSubstitutes = false; } ''
        mkdir -p "$out/bin"
        cd "$out/bin"
        ln -s {${sh (lib.getBin llvmPackages.llvm)}/bin/,}llvm-symbolizer
      '')
  ];

  configurePhase = ''
    runHook preConfigure

    substituteInPlace ./mk.config \
      --replace 'PREFIX=/usr/ccs' 'PREFIX=$(out)' \
      --replace 'BINDIR=$(PREFIX)/bin' "BINDIR=\$($outputBin)/bin" \
      --replace 'LIBDIR=$(PREFIX)/lib' "LIBDIR=\$($outputLib)/lib" \
      --replace 'MANDIR=$(PREFIX)/share/man' \
        "MANDIR=\$($outputMan)/share/man" \
      #

    substituteInPlace ./make/src/Makefile.mk \
      --replace 'HDRSDIR = $(PREFIX)/share/lib/make' \
        "HDRSDIR = \$($outputDev)/lib/make" \
      #

    substituteInPlace ./mk.config \
      --replace 'INSTALL=/usr/ucb/install' 'INSTALL=install' \
      --replace 'SUSBIN=/usr/5bin/posix' "SUSBIN=\$($outputBin)/5bin/posix" \
      --replace 'STRIP=strip' 'STRIP=true # strip' \
      --replace 'FLAGS=' 'FLAGS?=' \
      #

    (shopt -s globstar && sed -i ./**/Makefile.mk -e '${"s" +
      ''@ln -s \(\$(ROOT)\)\(\$(BINDIR)\)/\(.*\) \1\$(LIBDIR)/\(.*\)$@'' +
      ''ln -s \1\2/\3 \1\2/\4'' +
      "@"}')

    runHook postConfigure
  '';

  makeFlags = [
    "SHELL=${shell}"
    "POSIX_SHELL=${posixShell}"
  ];

  preBuild = let
    pipe = lib.pipe or (val: functions:
      let reverseApply = x: f: f x;
      in builtins.foldl' reverseApply val functions);
    makeFlagArrayBody = flags:
      lib.concatStrings
        (lib.mapAttrsToList
          (n: v: "  " + sh "${n}=${v}" + " \\\n")
          flags);
    makeFlagArray = name: flags:
      "${name}Array+=( \\\n${makeFlagArrayBody makeFlags})";

    makeFlags = pipe {
      CFLAGS = "-g -O";
      CXXFLAGS = "-g -O";
    } [
      (if !enableAsan then (x: x) else o: o // {
        CFLAGS = o.CFLAGS or "" + " -fsanitize=address";
        CXXFLAGS = o.CXXFLAGS or "" + " -fsanitize=address";
        LDFLAGS = o.LDFLAGS or "" + " -fsanitize=address";
      })
      (if !(enableAsan && asanDefaultOpts != "") then (x: x) else o: o // {
        LDFLAGS = o.LDFLAGS or " ${sh asanDefaultOptsC}" +
          " -DASAN_DEFAULT_OPTIONS=${sh "\"${asanDefaultOpts}\""}";
      })
      (if !enableFramePointer then (x: x) else o: o // {
        CFLAGS = o.CFLAGS or "" + " -fno-omit-frame-pointer";
        CXXFLAGS = o.CXXFLAGS or "" + " -fno-omit-frame-pointer";
      })
      (if !enableMsan then (x: x) else o: o // {
        CFLAGS = o.CFLAGS or "" + " -fsanitize=memory";
        CXXFLAGS = o.CXXFLAGS or "" + " -fsanitize=memory";
        LDFLAGS = o.LDFLAGS or "" + " -fsanitize=memory";
      })
      (if !(enableMsan && enableMsanTrackOrigins) then (x: x) else o: o // {
        CFLAGS = o.CFLAGS or "" + " -fsanitize-memory-track-origins";
        CXXFLAGS = o.CXXFLAGS or "" + " -fsanitize-memory-track-origins";
      })
      (if !enablePIE then (x: x) else o: o // {
        CFLAGS = o.CFLAGS or "" + " -fPIE";
        CXXFLAGS = o.CXXFLAGS or "" + " -fPIE";
        LDFLAGS = o.LDFLAGS or "" + " -pie";
      })
    ];
  in ''
    ${makeFlagArray "makeFlags" makeFlags}
  '';

  dontStrip = enableAsan || enableMsan;

  meta = with lib; {
    description =
      "A stable base for compiling other components of the Heirloom Project";
    homepage = http://heirloom.sourceforge.net/tools.html;
    license = with licenses; [ bsdOriginalUC caldera ccdl10 ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };

  passthru = {
    inherit shell posixShell;
  };
}
