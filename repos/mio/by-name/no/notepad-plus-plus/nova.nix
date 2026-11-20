# Notepad++ built natively on Windows by nova-nix.
#
# nova-nix's Windows stdenv lives in the release archive: copy this file into
# the unpacked nova-nix directory (the one holding pkgs/, bin/ and share/) and
# run there:
#
#   nova-nix build notepad-plus-plus.nix --store C:\nix\store
#
# The build is Notepad++'s own PowerEditor/gcc makefile; the pre-build .bat is
# replaced with the same header generation done by hand, so the build needs no
# cmd.exe/findstr behaviour.  Unlike the Linux/macOS package in package.nix
# this is a native Windows build, so the Wine-only "[Administrator]" patch is
# not applied.
let
  fetchurl = import ./pkgs/windows/fetchurl.nix;
  stdenv = import ./pkgs/windows/stdenv;
in
stdenv.mkDerivation rec {
  name = "notepad-plus-plus-${version}";
  version = "8.9.9.1";

  src = fetchurl {
    url = "https://github.com/notepad-plus-plus/notepad-plus-plus/archive/v${version}.tar.gz";
    hash = "sha256-219G2IVVFjPxFNOLqEZOOtLnyhf5UjsxPEqDhfCY2GY=";
  };

  dontConfigure = true;

  buildPhase = ''
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

    make -j4 -f "$PWD/PowerEditor/gcc/makefile" PREBUILD_EVENT_CMD=true VERBOSE=1
  '';

  installPhase = ''
    binDir=$(find . -maxdepth 1 -type d -name 'bin.*.x86_64' ! -name '*.build' | head -n1)
    if [ -z "$binDir" ] || [ ! -f "$binDir/notepad++.exe" ]; then
      echo "error: notepad++.exe not found under bin.*.x86_64" >&2
      find . -maxdepth 2 -type d -name 'bin*' -print >&2 || true
      exit 1
    fi
    mkdir -p "$out"
    cp -a "$binDir"/. "$out"/
    rm -f "$out/doLocalConf.xml"
  '';
}
