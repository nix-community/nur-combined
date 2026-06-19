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

  runCommand,
  makeWrapper,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tyck";
  version = "0.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "natkr";
    repo = "tyck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P6bW210ThAPESwpE6WA2pd8xRWqEq8Rq/aww4h3y/5Q=";
  };

  cargoHash = "sha256-DY29G0icWpEHgZg9hnys+QT5DF3CceSeEJxajcV0A7c=";

  env = {
    SQLX_OFFLINE = "true";
    BUILT_OVERRIDE_tyck_GIT_COMMIT_HASH = "cc8902e3e20e5e8af7807a638e37fb99e3251f05";
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
    migrations = runCommand "${finalAttrs.pname}-${finalAttrs.version}-migrations" { } ''
      cp -r ${finalAttrs.src}/migrations $out
    '';
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
