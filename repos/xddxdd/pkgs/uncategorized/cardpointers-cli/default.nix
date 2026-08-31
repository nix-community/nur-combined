{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  makeWrapper,
  curl,
  jq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cardpointers-cli";
  version = "1.0.7";
  src = fetchFromGitHub {
    owner = "cardpointers";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rK7CgcPmNt7uIQUG4Ek/4TU7bG1bSCyF3UddfTAJlo0=";
  };
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

  passthru.updateScript = nix-update-script { };
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
