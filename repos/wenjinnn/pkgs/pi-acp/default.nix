{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  nodejs-slim,
}:
let
  version = "0.0.33";
in
buildNpmPackage rec {
  pname = "pi-acp";
  inherit version;

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${version}";
    hash = "sha256-fENOOdooi4XbIDjcr02q8qzUCzdo2IW/Bca43SawZ44=";
  };

  npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-acp
    cp -r dist node_modules package.json $out/lib/node_modules/pi-acp/

    mkdir -p $out/bin
    makeWrapper ${nodejs-slim}/bin/node $out/bin/pi-acp \
      --add-flags "$out/lib/node_modules/pi-acp/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = licenses.mit;
    mainProgram = "pi-acp";
    platforms = platforms.all;
  };
}
