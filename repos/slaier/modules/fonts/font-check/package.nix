{ lib
, stdenv
, python3
, makeWrapper
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    fonttools
  ]);
in

stdenv.mkDerivation {
  pname = "font-check";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    pythonEnv
  ];

  installPhase = ''
    install -D -m 755 check_font.py $out/bin/font-check
    wrapProgram $out/bin/font-check \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
  '';

  meta = with lib; {
    description = "Font character support checker tool";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "font-check";
  };
}
