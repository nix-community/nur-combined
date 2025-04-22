{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, poppler
}:

stdenv.mkDerivation rec {
  pname = "ppm2pwg";
  version = "unstable-2024-08-17";

  src = fetchFromGitHub {
    owner = "attah";
    repo = "ppm2pwg";
    rev = "0c770cbc86aa73a3257f4df683f898ad461cb0c1";
    hash = "sha256-kcSx0FilehnVGYKkrpA9ItbJ6PrSjeKl80yqS5mwhD8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    poppler
  ];

  # fix: make: *** No rule to make target 'install'.  Stop.
  # https://github.com/attah/ppm2pwg/issues/26
  # TODO? use hexdump from nixpkgs
  installPhase = ''
    for bin in ppm2pwg pwg2ppm pdf2printable baselinify ippclient hexdump ippdecode bsplit; do
      install -D -m755 $bin $out/bin/$bin
    done
  '';

  meta = with lib; {
    description = "Misc printing utilities: baselinify bsplit hexdump ippclient ippdecode pdf2printable ppm2pwg pwg2ppm";
    homepage = "https://github.com/attah/ppm2pwg";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "ppm2pwg";
    platforms = platforms.all;
  };
}
