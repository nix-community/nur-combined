{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, poppler
}:

stdenv.mkDerivation rec {
  pname = "ppm2pwg";
  version = "unstable-2026-01-04";

  src = fetchFromGitHub {
    owner = "attah";
    repo = "ppm2pwg";
    rev = "1c3ff22486bac6fcdb257f94245fb3d455ab2dce";
    hash = "sha256-to9n7UXJUjywCoKcYw+u59jqY4CPjI5Jw3UE+8FGWnQ=";
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
    exclude_bins='hexdump|minimime'
    find . -mindepth 1 -maxdepth 1 -type f -executable -printf '%f\n' | grep -vxE "$exclude_bins" | while read bin; do
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
