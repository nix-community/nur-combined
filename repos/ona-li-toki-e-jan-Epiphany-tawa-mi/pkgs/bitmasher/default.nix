{ stdenv
, mypy
, python3
, fetchFromGitHub
, lib
}:


let source = "bitmasher.py";
in stdenv.mkDerivation  rec {
  pname   = "bitmasher";
  version = "6.327438247";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "BitMasher";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-4LJOcgEfzh8rbWlbKav8NzrxlE2KW+rTj+z3o7y78qo=";
  };

  nativeBuildInputs = [ mypy ];
  buildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild

    mypy "${source}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "${source}" "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A fast-paced text adventure game inside a ransomware-infected computer";
    homepage =
      "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/BitMasher";
    license     = licenses.gpl3Plus;
    mainProgram = "bitmasher";
  };
}
