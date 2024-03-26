{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "cowsaypl";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "cowsAyPL";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-S4uEi4KcivuXQVp7799hL24a+8APit5cwjfEDzp5nBY=";
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
