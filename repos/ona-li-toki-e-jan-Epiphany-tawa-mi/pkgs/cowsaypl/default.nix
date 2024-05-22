{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "cowsaypl";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "cowsAyPL";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-iSeKP/BtHXVzEdjABi5KCJlNX42lgQktN1ARGKX7OkU=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp cowsay.apl $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cowsay in GnuAPL";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/cowsAyPL";
    license     = licenses.mit;
    mainProgram = pname;
  };
}
