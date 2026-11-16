{
  lib,
  fetchFromGitHub,
  pkgsCross,
  wine,
}:

let
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
pkgsCross.mingwW64.stdenv.mkDerivation (finalAttrs: {
  pname = "notepadpp-windows";
  version = "8.9.9.1";

  src = fetchFromGitHub {
    owner = "notepad-plus-plus";
    repo = "notepad-plus-plus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yELw7W+LmKCv+glbHeTABNyK205QsU3eAuw0jc3M2kc=";
  };

  # wine/cmd for the upstream .bat pre-build; findstrShim completes Wine.
  nativeBuildInputs = [ wine ];

  enableParallelBuilding = true;
  dontConfigure = true;

  # Makefile resets CXX unless CROSS_COMPILE is set. Build from the source
  # root with an absolute makefile path (same as the MSYS2 PKGBUILD).
  # Upstream pre-build is: cmd //C NppLibsVersionH-generator.bat — run that
  # through Wine instead of synthesizing NppLibsVersion.h by hand.
  buildPhase = ''
    runHook preBuild

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

    make -j$NIX_BUILD_CORES \
      -f "$PWD/PowerEditor/gcc/makefile" \
      CROSS_COMPILE=${pkgsCross.mingwW64.stdenv.cc.targetPrefix} \
      VERBOSE=1

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
