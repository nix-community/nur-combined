{ boost
, cmake
, cmocka
, fetchgit
, git
, glib
, json_c
, lib
, pkg-config
, python310
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "tetrapol-kit";
  version = "2020.10.12";

  src = fetchgit {
    url = "https://brmlab.cz/git/tetrapol-kit.git";
    rev = "a82421cf3348d8a20509e8aeef1f2940a5543e71";
    sha256 = "sha256-gkoJnNhEnQIkWRcQNhCvmcMUgwVfNhJqdj5eLgxItOw=";
  };

  nativeBuildInputs = [ cmake git pkg-config ];

  installPhase = ''
    mkdir -p $out/bin
    cp apps/tetrapol_dump $out/bin 
    cp -r ../demod $out/ 
  '';

  buildInputs = [
    boost
    cmocka
    glib
    json_c
    pkg-config

    (python310.withPackages (ps: with ps; [
      six
    ]))
  ];

  meta = with lib; {
    description = "Experimental TETRAPOL receiver and decoder";
    homepage = "https://brmlab.cz/project/tetrapol/start";
    license = licenses.gpl2;
  };
}
