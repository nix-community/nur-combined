{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "2021-04-26";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "2409741e19577421ed8a1630b738f4facca1b041";
    hash = "sha256-/xbCThs/kGN/4Gym8hXW1FvlhB4Jd4Y80Y6YQl7km9E=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-nNK1Hv3MiD1XbYw5aqjk4AmFdN3LHCvUIFHEX75Ox0Y=";

  buildPhase = ''
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
