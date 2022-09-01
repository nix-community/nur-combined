{ lib, buildGoModule, fetchgit, scdoc }:

buildGoModule rec {
  pname = "comitium";
  version = "1.8.0";

  src = fetchgit {
    url = "git://git.nytpu.com/comitium";
    rev = "v${version}";
    hash = "sha256-an3favwpTTf61ecfAmasZY4fBV8gIH3hWDbIiImtIVs=";
  };

  vendorHash = "sha256-dEywsGjLuaZ+Yv5IfuPHcKYZ8hyZ1Qf46LOF2RGcpxo=";

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
    platforms = platforms.unix;
  };
}
