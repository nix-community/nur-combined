{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "rose-pine-kitty";
  version = "0-unstable-2023-09-02";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "kitty";
    rev = "788bf1bf1a688dff9bbacbd9e516d83ac7dbd216";
    hash = "sha256-AcMVkliLGuabZVGkfQPLhfspkaTZxPG5GyuJdzA4uSg=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/kitty
    cp ./dist/*.conf $out/share/kitty/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Soho vibes for kitty";
    homepage = "https://github.com/rose-pine/kitty";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
