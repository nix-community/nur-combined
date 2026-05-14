{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, nodejs_24
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "aicommits";
  version = "3.1.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/aicommits/-/${pname}-${version}.tgz";
    hash = "sha256-yDJgZ7HedmZSdc6FuepjDVKAk9knvhAACzwin06H/XU=";
  };

  sourceRoot = "package";
  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/${pname} $out/bin
    cp -r dist $out/share/${pname}
    makeWrapper ${nodejs_24}/bin/node $out/bin/${pname} \
      --add-flags $out/share/${pname}/dist/cli.mjs
    ln -s $out/bin/${pname} $out/bin/aic
    runHook postInstall
  '';

  meta = {
    description = "AI-assisted git commit message generator";
    homepage = "https://github.com/Nutlope/aicommits";
    license = lib.licenses.mit;
    mainProgram = "aicommits";
  };
}
