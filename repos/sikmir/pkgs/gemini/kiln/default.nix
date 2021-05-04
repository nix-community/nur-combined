{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "kiln";
  version = "2021-05-01";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "a6f582f284224a2e45241a0ff1efa14627f5882a";
    hash = "sha256-N/RWeSlwCnkhPVNFPu3UltKH6DXgwEDnEops5tCmqBo=";
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
