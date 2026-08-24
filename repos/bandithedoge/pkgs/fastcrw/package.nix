{
  fetchFromGitHub,
  nix-update-script,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastcrw";
  version = "0.31.0";
  src = fetchFromGitHub {
    owner = "us";
    repo = "crw";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xHB7LibVrWjM+X23ImIJC8yBDy5lBb8XR7wn7hXJ9aA=";
  };

  cargoHash = "sha256-SLXRifUKspCHfJ8jHUlTv9SvldtDgosOqLoxLhq7LU0=";

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
