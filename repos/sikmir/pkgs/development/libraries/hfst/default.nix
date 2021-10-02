{ lib, stdenv, fetchFromGitHub, autoreconfHook, bison, flex }:

stdenv.mkDerivation rec {
  pname = "hfst";
  version = "3.15.5";

  src = fetchFromGitHub {
    owner = "hfst";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BvcueEdu+4rTeazvZ08BtNHkvGBIZi6W1+Fn3tJMxac=";
  };

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with lib; {
    description = "Helsinki Finite-State Technology (library and application suite)";
    homepage = "https://hfst.github.io";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
