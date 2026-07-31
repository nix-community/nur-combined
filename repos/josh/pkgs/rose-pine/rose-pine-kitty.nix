{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rose-pine-kitty";
  version = "0-unstable-2025-11-05";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "kitty";
    rev = "efd4f01cb9887feaa7114ff21a887464295d0205";
    hash = "sha256-GyRyflUVp1BHg6S0emZ6ViALx8L130npnfyZQmdxhfA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/kitty
    cp ./dist/*.conf $out/share/kitty/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    files = runCommand "test-rose-pine-kitty-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/kitty/rose-pine.conf
      test -s ${finalAttrs.finalPackage}/share/kitty/rose-pine-moon.conf
      test -s ${finalAttrs.finalPackage}/share/kitty/rose-pine-dawn.conf
      touch $out
    '';
  };

  meta = {
    description = "Soho vibes for kitty";
    homepage = "https://github.com/rose-pine/kitty";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
