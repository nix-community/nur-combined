{
  lib,
  stdenv,
  fetchFromGitHub,
  libpng,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "datamaps";
  version = "0-unstable-2014-08-19";

  src = fetchFromGitHub {
    owner = "e-n-f";
    repo = "datamaps";
    rev = "76e620adabbedabd6866b23b30c145b53bae751e";
    hash = "sha256-UwrVbBataiHMPMwIUd7qjYChKaVGB48V2bHFV51fuOU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libpng ];

  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  installPhase = ''
    for tool in encode enumerate merge render; do
      install -Dm755 $tool $out/bin/datamaps-$tool
    done
  '';

  meta = {
    description = "Indexes points and lines and generates map tiles to display them";
    homepage = "https://github.com/e-n-f/datamaps";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
