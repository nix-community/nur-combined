{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  makeBinaryWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "git-cz";
  version = "4.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/git-cz/-/git-cz-${finalAttrs.version}.tgz";
    hash = "sha256-SKznj4R24Z8oQ1yIW9wsUcndosEreuj8xXre2puHNDs=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [makeBinaryWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/git-cz $out/bin
    cp -r package/* $out/share/git-cz/

    makeWrapper ${lib.getExe nodejs} $out/bin/git-cz \
      --add-flags "$out/share/git-cz/bin/git-cz.js"

    makeWrapper ${lib.getExe nodejs} $out/bin/gitcz \
      --add-flags "$out/share/git-cz/bin/git-cz.js"

    runHook postInstall
  '';

  meta = {
    description = "Semantic emojified git commit";
    homepage = "https://github.com/streamich/git-cz";
    license = lib.licenses.unlicense;
    maintainers = [];
    mainProgram = "git-cz";
  };
})
