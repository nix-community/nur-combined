{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "multi-account-containers";
  version = "8.4.1";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "multi-account-containers";
    tag = finalAttrs.version;
    hash = "sha256-wjxzjVwrFTkImWKb05CTkivQWvwfJ9t/6A9OZ1RR9Fs=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/multi-account-containers
    cp -r src/. $out/share/multi-account-containers/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/mozilla/multi-account-containers/releases/tag/${finalAttrs.version}";
    description = "Firefox Multi-Account Containers — keep your identities separate with colored container tabs";
    homepage = "https://github.com/mozilla/multi-account-containers";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
