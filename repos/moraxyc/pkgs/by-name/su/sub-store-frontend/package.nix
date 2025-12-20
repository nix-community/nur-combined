{
  lib,
  stdenv,
  fetchFromGitHub,

  pnpm_10,
  pnpm ? pnpm_10,
  nix-update-script,
  pnpmConfigHook,
  fetchPnpmDeps,

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
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-HEeNYLKvzO/RQWYnm5gqRjTrXiiCxKUxf3bcRvz+O4k=";
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
