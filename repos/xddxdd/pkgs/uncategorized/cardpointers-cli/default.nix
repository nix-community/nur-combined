{
  sources,
  stdenvNoCC,
  lib,
  makeWrapper,
  curl,
  jq,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.cardpointers-cli) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 cardpointers $out/bin/cardpointers
    wrapProgram $out/bin/cardpointers \
      --suffix PATH : "${
        lib.makeBinPath [
          curl
          jq
        ]
      }"

    runHook postInstall
  '';

  doInstallCheck = false;

  meta = {
    changelog = "https://github.com/cardpointers/cli/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Credit card rewards CLI for CardPointers";
    homepage = "https://github.com/cardpointers/cli";
    license = lib.licenses.bsl11;
    mainProgram = "cardpointers";
    platforms = lib.platforms.all;
  };
})
