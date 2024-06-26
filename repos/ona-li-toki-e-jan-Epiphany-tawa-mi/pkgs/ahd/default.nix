{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "ahd";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "AHD";
    rev   = version;
    hash  = "sha256-pVHz6H9WoQpbfS3LYyGVJOkXx/BxaV4B3sE4O+vb1So=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ahd.apl $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hexdump utility";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}
