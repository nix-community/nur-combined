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
  version = "2.50.1";

  src = fetchFromGitHub {
    owner = "violentmonkey";
    repo = "violentmonkey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r4UQetuJ83LQqfzEdT0B/Yz8vNvGJvFV6GXSASJ9BZE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-YYtGassxZaKbwpQ6DJ9hyKvPMYjjh8t/B6rlSxdhaUI=";
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
