{ lib, buildGoModule, fetchgit, scdoc }:

buildGoModule rec {
  pname = "comitium";
  version = "1.8.1";

  src = fetchgit {
    url = "git://git.nytpu.com/comitium";
    rev = "v${version}";
    hash = "sha256-rtsC9SAddRdmu82BRrZOEOq53ZYSOUGGZJDdTYs4WKY=";
  };

  vendorHash = "sha256-6xtXTmSqaN2me0kyRk948ASNNtv7P5XBvtv9UWjNHoo=";

  nativeBuildInputs = [ scdoc ];

  buildPhase = ''
    runHook preBuild
    make COMMIT=tarball
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A feed aggregator for gemini supporting many formats and protocols";
    homepage = "https://git.nytpu.com/comitium/about/";
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
