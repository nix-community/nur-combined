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
  pname = "equicord";
  version = "2026-10-08";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = "${finalAttrs.version}";
    hash = "sha256-38mMUaDgS0nYwrW2WceQmuHDJk1vFU1PEi7HWvNxiZk=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-hBZHHB5kRkNqep5vWMMnwIblNCAOZvLotDjJUJd9iMU=";
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
