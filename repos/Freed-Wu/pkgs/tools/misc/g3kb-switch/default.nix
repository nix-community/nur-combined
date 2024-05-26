{ lib
, stdenv
, cmake
, pkg-config
, glib
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "g3kb-switch";
  src = fetchFromGitHub {
    owner = "lyokha";
    repo = "g3kb-switch";
    rev = "cc2640cd3eaa896c7dbbf148f742e2f1a3cac768";
    sha256 = "sha256-ba3pyidUlrftiDc/sfxDmG4Z4qYYI0+BJeYRoG4BzvE=";
  };

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
