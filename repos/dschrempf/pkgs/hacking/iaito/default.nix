{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qttools,
  radare2,
  wrapQtAppsHook,
  zip,
}:

# NOTE: The QT translation files are not found by the executable.

# NOTE: Iaito reports a mismatch of the radare2 build and runtime versions. The
# statement is wrong. The version string comparison fails somehow.

stdenv.mkDerivation rec {
  pname = "iaito";
  version = "5.7.0-dev";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = pname;
    rev = "721886dffdcd644c31ce1558005ad5a1e0626452";
    hash = "sha256-thVkpaRb/EV4azD3svN9+1/ZXIHPgS6QMKTqVZezHcQ=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dschrempf ];
  };

  nativeBuildInputs = [
    pkg-config
    qttools
    wrapQtAppsHook
    zip
  ];
  buildInputs = [ radare2 ];
  # propagatedBuildInputs = [ ];

  # Weird installation paths (/usr/...) crash the installer if DESTDIR is unset.
  makeFlags = [ "DESTDIR=$(out)" ];

  # Handle weird installation paths.
  preFixup = ''
    # Binary.
    mv $out/usr/local/bin $out/

    # Misc.
    mv $out/usr/local/share $out/

    # Translations.
    mv $out/$out/share/iaito $out/share/

    # Clean up.
    (cd $out; rmdir -p usr/local)
    (cd $out; rmdir -p ''${out#/}/share)
  '';
}
