{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hi3-ii-martian-font";
  version = "0-unstable-2023-10-12";
  src = fetchFromGitHub {
    owner = "Wenti-D";
    repo = "HI3IIMartianFont";
    rev = "763609486b6e2f3af60903cd6ae52a61a278438f";
    hash = "sha256-X1Yx2ADlEYZv0tpElkdv9kzn4lB+SDwpDq2q2tVvl+g=";
  };
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec install -m644 {} $out/share/fonts/opentype/ \;

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
    description = "Font for Martian in Honkai Impact 3rd";
    homepage = "https://github.com/Wenti-D/HI3IIMartianFont";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})
