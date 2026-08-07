{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation rec {
  pname = "exo";
  version = "1.0.71";

  src = fetchurl {
    url = "https://github.com/exo-explore/exo/releases/download/v${version}/EXO-${version}.dmg";
    hash = "sha256-vIGiPsZHqZXF+CN4V+dJvD3nuo7EDyqrOYhsGgS+qsc=";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    7zz x $src
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "Exo.app" $out/Applications/ 2>/dev/null || cp -r *.app $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Run your own AI cluster at home with everyday devices";
    homepage = "https://github.com/exo-explore/exo";
    license = licenses.asl20;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "exo";
  };
}
