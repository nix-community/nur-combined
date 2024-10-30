{ stdenv
, fetchFromGitHub
, netcat-openbsd
, makeWrapper
, lib
}:

stdenv.mkDerivation rec {
  pname   = "netcatchat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "${pname}";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-ST706XwdEUlcwXX9xtONkhzlFANybRgJxBVZdVnWoIo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs       = [ netcat-openbsd ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp netcatchat.sh $out/bin/netcatchat
    wrapProgram $out/bin/netcatchat --prefix PATH : ${lib.makeBinPath [ netcat-openbsd ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A simple command-line chat server and client using netcat";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/netcatchat";
    license     = licenses.mit;
    mainProgram = pname;
  };
}
