{
  lib,
  fetchFromGitHub,
  pkgsCross,
  wine,
}:

let
  mingwStdenv = pkgsCross.mingwW64.stdenv;
  # The gcc makefile's pre-build event runs NppLibsVersionH-generator.bat through
  # `cmd`. Wine's server cannot start inside the darwin sandbox (it needs Mach
  # ports), so on darwin the header is generated natively and the event is
  # skipped; see buildPhase.
  buildIsDarwin = mingwStdenv.buildPlatform.isDarwin;

  # Wine's builtin findstr lacks [character class] regex support, which breaks
  # PowerEditor/src/NppLibsVersionH-generator.bat. Prefer this native PE via
  # WINEDLLOVERRIDES when running that bat under Wine during the build.
  findstrShim = pkgsCross.mingwW64.stdenv.mkDerivation {
    name = "notepadpp-findstr-shim";
    dontUnpack = true;
    buildPhase = ''
      $CC -O2 -o findstr.exe ${./findstr.c} -s
    '';
    installPhase = ''
      mkdir -p $out
      cp findstr.exe $out/
    '';
  };
in
mingwStdenv.mkDerivation (finalAttrs: {
  pname = "notepadpp-windows";
  version = "8.9.9.1";

  src = fetchFromGitHub {
    owner = "notepad-plus-plus";
    repo = "notepad-plus-plus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yELw7W+LmKCv+glbHeTABNyK205QsU3eAuw0jc3M2kc=";
  };

  # wine/cmd for the upstream .bat pre-build; findstrShim completes Wine.
  nativeBuildInputs = lib.optional (!buildIsDarwin) wine;

  # lexilla's makefile keys its macOS branch off `uname`, which on a darwin
  # builder adds Apple-only `-arch arm64 -arch x86_64` (and -dynamiclib) to the
  # MinGW cross compiler. That branch only exists for native macOS dylibs, which
  # this derivation never builds, so require an explicit opt-in to take it.
  postPatch = ''
    substituteInPlace lexilla/src/makefile \
      --replace-fail 'ifeq ($(shell uname),Darwin)' 'ifeq ($(NPP_NATIVE_MACOS),1)'
  '';

  enableParallelBuilding = true;
  dontConfigure = true;

  # Makefile resets CXX unless CROSS_COMPILE is set. Build from the source
  # root with an absolute makefile path (same as the MSYS2 PKGBUILD).
  # Upstream pre-build is: cmd //C NppLibsVersionH-generator.bat — run that
  # through Wine instead of synthesizing NppLibsVersion.h by hand.
  buildPhase = ''
    runHook preBuild
  ''
  + lib.optionalString buildIsDarwin ''
    # Read the same three VERSION_* defines NppLibsVersionH-generator.bat greps
    # out of its source tree and write the header the makefile would have
    # generated, so nothing has to run under Wine.
    # Fail the build instead of shipping empty version macros if upstream ever
    # renames one of the files NppLibsVersionH-generator.bat used to read.
    libs_version() {
      value=$(grep -m1 "^[[:space:]]*#define[[:space:]]*$2[[:space:]]" "$1" | sed 's/[^"]*"\(.*\)".*/\1/' | tr -d '\015')
      if [ -z "$value" ]; then
        echo "error: $2 not found in $1" >&2
        return 1
      fi
      printf '%s\n' "$value"
    }
    sci_version=$(libs_version scintilla/win32/ScintRes.rc VERSION_SCINTILLA)
    lexilla_version=$(libs_version lexilla/src/LexillaVersion.rc VERSION_LEXILLA)
    boost_version=$(libs_version boostregex/boost/version.hpp BOOST_LIB_VERSION)
    {
      echo '// NppLibsVersion.h'
      echo '// - maintained by NppLibsVersionH-generator.bat'
      printf '#define NPP_SCINTILLA_VERSION "%s"\n' "$sci_version"
      printf '#define NPP_LEXILLA_VERSION "%s"\n' "$lexilla_version"
      printf '#define NPP_BOOST_REGEX_VERSION "%s"\n' "$boost_version"
    } > PowerEditor/src/NppLibsVersion.h
  ''
  + lib.optionalString (!buildIsDarwin) ''
    export HOME="$TMPDIR/wine-home"
    export WINEPREFIX="$TMPDIR/wineprefix"
    export WINEARCH=win64
    export WINEDEBUG="-all"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;findstr.exe=native"
    mkdir -p "$HOME" "$WINEPREFIX"

    wineboot --init
    wineserver -w
    install -m755 ${findstrShim}/findstr.exe "$WINEPREFIX/drive_c/windows/system32/findstr.exe"
    if [ -d "$WINEPREFIX/drive_c/windows/syswow64" ]; then
      install -m755 ${findstrShim}/findstr.exe "$WINEPREFIX/drive_c/windows/syswow64/findstr.exe"
    fi

    mkdir -p "$TMPDIR/bin"
    printf '%s\n' \
      '#!/bin/sh' \
      '# Upstream makefile: cmd //C ".../NppLibsVersionH-generator.bat"' \
      'exec wine cmd "$@"' \
      > "$TMPDIR/bin/cmd"
    chmod +x "$TMPDIR/bin/cmd"
    export PATH="$TMPDIR/bin:$PATH"
  ''
  + ''
    make -j$NIX_BUILD_CORES \
      -f "$PWD/PowerEditor/gcc/makefile" \
      CROSS_COMPILE=${mingwStdenv.cc.targetPrefix} \
      VERBOSE=1 ${lib.optionalString buildIsDarwin "PREBUILD_EVENT_CMD=true"}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    binDir=$(find . -maxdepth 1 -type d -name 'bin.*.x86_64' ! -name '*.build' | head -n1)
    if [ -z "$binDir" ] || [ ! -f "$binDir/notepad++.exe" ]; then
      echo "error: notepad++.exe not found under bin.*.x86_64" >&2
      find . -maxdepth 2 -type d -name 'bin*' -print >&2 || true
      exit 1
    fi
    mkdir -p "$out"
    cp -a "$binDir"/. "$out/"
    # Prefer AppData (via runtime file maps) over portable local conf.
    rm -f "$out/doLocalConf.xml"
    runHook postInstall
  '';

  # hostPlatform is Windows when cross-compiling; omit platforms so nixpkgs
  # does not reject this nested drv during Linux/Darwin wrapper eval.
  meta = {
    description = "Notepad++ Windows build (MinGW cross-compiled)";
    homepage = "https://notepad-plus-plus.org/";
    license = lib.licenses.gpl3Plus;
  };
})
