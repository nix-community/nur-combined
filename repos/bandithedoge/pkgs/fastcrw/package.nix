{
  fetchFromGitHub,
  nix-update-script,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastcrw";
  version = "0.33.0";
  src = fetchFromGitHub {
    owner = "us";
    repo = "crw";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ltZoCLgIR7jBBsyggLwZspwqCNspH4+jqpadyQ2HS/0=";
  };

  cargoHash = "sha256-G4N82svyVX9MXRHLH9nrPXVl6PQWxVwzr8eRKYwezic=";

  checkFlags = [
    "--skip="
    "sitemap::tests::fetch_sitemap*"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, lightweight Firecrawl alternative in Rust";
    homepage = "https://fastcrw.com";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "crw";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
