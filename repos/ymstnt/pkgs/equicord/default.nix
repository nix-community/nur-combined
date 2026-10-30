{
  fetchFromGitHub,
  git,
  lib,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
  nix-update-script,
  buildWebExtension ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  # Upstream switched from date tags (e.g. 2026-10-08) to semver tags (e.g. v1.15.13.0).
  # The old date tags still exist, so the update script only matches the semver ones.
  pname = "equicord";
  version = "1.15.14.0";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ijNxC/uR3Wy4JX/6qNnNGQwS5752+vK2T26N1bsLeG4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-awZhZFF0v1rcEIL/W3F22Zef0T6ZkuDp1w0FdwO0FWs=";
  };

  nativeBuildInputs = [
    git
    nodejs
    pnpmConfigHook
    pnpm_11
  ];

  env = {
    EQUICORD_REMOTE = "${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    EQUICORD_HASH = "${finalAttrs.src.tag}";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run ${if buildWebExtension then "buildWeb" else "build"} \
      -- --standalone --disable-updater

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/${lib.optionalString buildWebExtension "chromium-unpacked/"} $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(\\d+\\.\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    description = "Other cutest Discord client mod";
    homepage = "https://github.com/Equicord/Equicord";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
