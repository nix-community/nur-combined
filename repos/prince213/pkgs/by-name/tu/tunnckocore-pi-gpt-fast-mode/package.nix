{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "tunnckocore-pi-gpt-fast-mode";
  version = "0.4.0-unstable-2026-10-01";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tunnckoCore";
    repo = "pi-gpt-fast-mode";
    rev = "0d9baba259fc9231bc10d4568b738971151fdba8";
    hash = "sha256-OWd1yVNk9oXS28BN+B35fBke6To08zyzMGwUgQDSQEo=";
  };

  postPatch = ''
    sed -i -e '/SUPPORTED_MODELS =/a\
      "openai/gpt-6-astra",\
      "openai/gpt-6-luna",\
      "openai/gpt-6-sol",\
      "openai/gpt-6.1-sol",\
      "openai-codex/gpt-6-astra",\
      "openai-codex/gpt-6-luna",\
      "openai-codex/gpt-6-sol",\
      "openai-codex/gpt-6.1-sol",\
    ' src/index.ts
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src package.json $out

    runHook postInstall
  '';

  meta = {
    description = "Toggle GPT Fast mode for the Pi coding agent";
    homepage = "https://github.com/tunnckoCore/pi-gpt-fast-mode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
