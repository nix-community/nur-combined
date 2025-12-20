{
  lib,
  stdenv,
  fetchFromGitHub,

  pnpm_10,
  pnpm ? pnpm_10,
  nix-update-script,

  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sub-store-frontend";
  version = "2.15.85";

  src = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store-Front-End";
    tag = finalAttrs.version;
    hash = "sha256-K7tAqbM7cQpmZmRQFwJhpiesUoPzvXEKu5q0pYsj+ZA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    pnpm
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-HDiexse1QQ+6sJFnpcbnHd28yBDfCBJoQ9W1P4nEstE=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sub-Store Progressive Web App";
    homepage = "https://github.com/sub-store-org/Sub-Store-Front-End";
    changelog = "https://github.com/sub-store-org/Sub-Store-Front-End/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "sub-store-frontend";
    platforms = nodejs.meta.platforms;
  };
})
