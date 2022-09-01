{ lib, stdenv, fetchFromGitHub, zig }:

stdenv.mkDerivation rec {
  pname = "gurl";
  version = "2021-03-06";

  src = fetchFromGitHub {
    owner = "MasterQ32";
    repo = pname;
    rev = "c6491a0760c125ca50d86860f77b544f729d8885";
    hash = "sha256-l7WasR1rdD6DV3JWDIGcUlVkypnIKLNoKaVbibdibQc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig ];

  buildPhase = ''
    export HOME=$TMPDIR
    zig build -Drelease-safe=true -Dcpu=baseline
  '';

  installPhase = ''
    install -Dm755 zig-out/bin/gurl -t $out/bin
  '';

  meta = with lib; {
    description = "A curl-like cli application to interact with Gemini sites";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true; # https://github.com/MasterQ32/gurl/issues/5
  };
}
