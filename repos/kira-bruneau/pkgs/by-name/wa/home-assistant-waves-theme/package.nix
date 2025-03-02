{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "home-assistant-waves-theme";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "tgcowell";
    repo = "waves";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JWMUf6WNBmFcV9HjdHLsmeLLm+5VqxcdxGDsmtpLnmM=";
  };

  installPhase = ''
    runHook preInstall
    cp -r . "$out"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Blend of 2 themes found within the Home Assistant community";
    homepage = "https://github.com/tgcowell/waves";
    maintainers = with lib.maintainers; [ kira-bruneau ];
    mainProgram = "home-assistant-waves-theme";
    platforms = lib.platforms.all;
  };
})
