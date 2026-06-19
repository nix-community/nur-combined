{
  kagi-ken-cli,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "pi-kagi";
  version = "0.1.0";

  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp package.json index.js $out/

    runHook postInstall
  '';

  propagatedBuildInputs = [
    kagi-ken-cli
  ];

  meta = {
    description = "Pi extension exposing Kagi search and summarization via kagi-ken-cli";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
