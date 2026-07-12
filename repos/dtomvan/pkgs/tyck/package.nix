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
  rev = "21f3be623d5f37f9a8b45377e49200e137775ac1";
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tyck";
  version = "0.1.0-unstable-2026-07-12";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "natkr";
    repo = "tyck";
    inherit rev;
    hash = "sha256-LGlr+ik1112by4MXgbaT71smkG5YtjtoS/xtxreSbes=";
  };

  cargoHash = "sha256-9fOTvv2yoE0x+kaIFXvi3wkZuwFYO2mj1UD6AJ6WSsE=";

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
      --set-default TYCK_COMMIT_URL "${finalAttrs.src.gitRepoUrl}/src/commit/${rev}"
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
