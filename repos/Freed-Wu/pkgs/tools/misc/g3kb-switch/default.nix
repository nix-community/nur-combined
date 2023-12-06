{ mySources
, lib
, stdenv
, cmake
, pkg-config
, glib
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  inherit (mySources.g3kb-switch) pname version src;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    glib
  ];

  meta = with lib; {
    homepage = "https://github.com/lyokha/g3kb-switch";
    description = "CLI keyboard layout switcher for GNOME Shell";
    license = licenses.bsd2;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
