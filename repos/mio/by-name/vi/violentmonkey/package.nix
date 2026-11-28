{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm,
  pnpmConfigHook,
  nodejs_22,
  fetchPnpmDeps,
  nix-update-script,
  writeShellApplication,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "violentmonkey";
  version = "2.50.2";

  src = fetchFromGitHub {
    owner = "violentmonkey";
    repo = "violentmonkey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FFks+q8Q0NojTx0qT7vPmmhDPX9CB0Q9hE8Xqgf3ckw=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-U5sLJLOV4x23FZa/arfyEC3BkhSvYQca8Swr0keR9UY=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/violentmonkey
    # After build, it usually outputs to dist/
    cp -r dist/. $out/share/violentmonkey/
    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-violentmonkey";
    text = ''
      export UPDATE_NIX_ATTR_PATH="violentmonkey"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    changelog = "https://github.com/violentmonkey/violentmonkey/releases/tag/v${finalAttrs.version}";
    description = "Violentmonkey provides userscripts support for browsers";
    homepage = "https://violentmonkey.github.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
