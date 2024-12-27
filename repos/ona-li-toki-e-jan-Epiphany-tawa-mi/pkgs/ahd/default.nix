{ stdenv
, fetchFromGitHub
, lib
, cbqn
}:

stdenv.mkDerivation rec {
  pname   = "ahd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "AHD";
    rev   = version;
    hash  = "sha256-wbVPoyizJ1Mf2op7jS6GQD4Rqfkq0HiF3/c2UJlYmzE=";
  };

  nativeBuildInputs = [ cbqn ];
  buildInputs = [ cbqn ];

  buildPhase = ''
    runHook preBuild

    bqn test.bqn

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp ahd.bqn "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hexdump utility";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}
