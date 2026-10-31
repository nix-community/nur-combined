{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-frost";
  version = "nightly-unstable-2026-10-31";

  src = fetchFromGitHub {
    owner = "gaboolic";
    repo = "rime-frost";
    rev = "c3290dff20671593d64bc3118c62a47df59dd62c";
    hash = "sha256-VLmf2Csigym/BX1b4yp8kX1Tsf38UTC1vxQvpO8Atd8=";
  };

  installPhase = ''
    runHook preInstall

    rm -rf others README.md .git*

    mv default.yaml rime_frost_suggestion.yaml

    mkdir -p $out/share
    cp -r . $out/share/rime-data

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Clean and accurately weighted Simplified Chinese Rime dictionary, rebuilt from rime-ice";
    longDescription = ''
      Frost Pinyin (白霜拼音) is a Rime dictionary rebuilt from rime-ice,
      with word and character frequencies recalculated from a 745M-character
      high-quality corpus. It removes unhealthy, rare, and non-word entries,
      and drops the Tencent word vector dictionary that hurts sentence
      accuracy. According to the upstream benchmarks it outperforms rime-ice
      on sentence accuracy both with and without a grammar model.

      To enable the upstream `default.yaml`
      (provided as `rime_frost_suggestion.yaml`),
      add the following to your `default.custom.yaml`:

      ```yaml
      patch:
        __include: rime_frost_suggestion:/
      ```
    '';
    homepage = "https://github.com/gaboolic/rime-frost";
    changelog = "https://github.com/gaboolic/rime-frost/releases";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
}
