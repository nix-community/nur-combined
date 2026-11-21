{
  lib,
  fetchFromGitHub,
  pkgsCross,
}:

let
  mingwStdenv = pkgsCross.mingwW64.stdenv;
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

  # Under Wine the process token is always a member of BUILTIN\Administrators,
  # so the title bar ends in a meaningless " [Administrator]" on Linux/macOS.
  patches = [ ./patches/no-administrator-title.patch ];

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

  # Upstream's pre-build event is `cmd //C NppLibsVersionH-generator.bat`, which
  # needs Wine, and Wine's server cannot start inside the Nix sandbox on darwin
  # ("Can't check in server_mach_port"). Instead of a Wine path on Linux and a
  # shell reimplementation on darwin, both platforms run the reimplementation
  # and skip the event, so the build logic is identical everywhere and the
  # payload needs no Wine at all.
  # The Makefile resets CXX unless CROSS_COMPILE is set. Build from the source
  # root with an absolute makefile path (same as the MSYS2 PKGBUILD).
  buildPhase = ''
    runHook preBuild

    # Read the same three VERSION_* defines NppLibsVersionH-generator.bat greps
    # out of its source tree and write the header the makefile would have
    # generated. Fail the build instead of shipping empty version macros if
    # upstream ever renames one of the files that .bat reads.
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

    make -j$NIX_BUILD_CORES \
      -f "$PWD/PowerEditor/gcc/makefile" \
      CROSS_COMPILE=${mingwStdenv.cc.targetPrefix} \
      VERBOSE=1 PREBUILD_EVENT_CMD=true

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
