{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-dict";
  version = "0-unstable-2026-03-14";
  src = fetchFromGitHub {
    owner = "Iorest";
    repo = "rime-dict";
    rev = "a2057baecf53e5a45dfd5b72f1ec50773d8c9271";
    hash = "sha256-8XkMAy2PLu17kWexU9il6jPQNaDQ3IujFbr2bLno1QM=";
  };
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    find $src -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME 词库增强";
    homepage = "https://github.com/Iorest/rime-dict";
    license = with lib.licenses; [ unfree ];
  };
})
