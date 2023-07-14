{ lib
, stdenv
, cmake
, pkg-config
, glib
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "g3kb-switch";
  version = "1.3";
  src = fetchFromGitHub {
    owner = "lyokha";
    repo = "g3kb-switch";
    rev = version;
    sha256 = "sha256-90ELWRVHkdLLQoUIQuE1yc2F1Rj9UOMcxmKTmK1S8yY=";
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
