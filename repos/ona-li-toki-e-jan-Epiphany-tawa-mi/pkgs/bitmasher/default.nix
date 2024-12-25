{ stdenv
, mypy
, python3
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  pname   = "bitmasher";
  version = "7.5385325985";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "BitMasher";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-2bE0QA82yQLa2A8snnhXu8DptDOsnfF/g2bg6SrNwCY=";
  };

  buildPhase = ''
    runHook preBuild

    EXTRA_CFLAGS="-O3" ./build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "${pname}" "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A fast-paced text adventure game inside a ransomware-infected computer";
    homepage =
      "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/BitMasher";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}
