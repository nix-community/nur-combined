{ stdenv
, fetchFromGitHub
, lib
, gnu-cobol
, gmp
}:

stdenv.mkDerivation rec {
  pname   = "cobol-dvd-thingy";
  version = "0.1.0";

  # The latest version (0.1.0) has build errors, which were fixed in this
  # commit.
  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "COBOL-DVD-Thingy";
    rev   = "9bdb85792d6c2bd232e984b64646986d6a05b13c";
    hash  = "sha256-Ard43xckfNwjb1d8VNXKDIoZfKi5n1WM+MLM2yzAftw=";
  };

  # We have to use gnu-cobol.bin because gnu-cobol doesn't properly output it's
  # binary, I think.
  nativeBuildInputs = [ gnu-cobol.bin gmp ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp cobol-dvd-thing.out $out/bin/cobol-dvd-thingy

    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal screensaver similar to that of DVD players";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/COBOL-DVD-Thingy";
    license     = licenses.mit;
    mainProgram = "cobol-dvd-thingy";
  };
}
