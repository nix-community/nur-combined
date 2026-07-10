{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  libgit2,
  openssl,
  sqlite,
  zlib,
  nix-update-script,
  makeWrapper,
}:

let
  rev = "1962fb9d39152dbd3901a0373ed3f900f3d526d4";
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tyck";
  version = "0.1.0-unstable-2026-07-10";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "dtomvan";
    repo = "tyck";
    inherit rev;
    hash = "sha256-xtzfcx6JHCRvN+9A3ht1A4DTYdetsZoumAr/FfWBVW4=";
  };

  cargoHash = "sha256-jEJ9F9P0wgwS4NXnqrR8P8fPwnpGA/184/BLoAbYEhg=";

  env = {
    SQLX_OFFLINE = "true";
    BUILT_OVERRIDE_tyck_GIT_COMMIT_HASH = rev;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libgit2
    openssl
    sqlite
    zlib
  ];

  postInstall = ''
    wrapProgram $out/bin/tyck \
      --set-default TYCK_COMMIT_URL "${finalAttrs.src.gitRepoUrl}/src/tag/v${finalAttrs.version}"
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Minimal comment engine for (otherwise) static blogs";
    homepage = "https://codeberg.org/natkr/tyck";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.linux;
    mainProgram = "tyck";
  };
})
