{
  fetchFromGitHub,
  nix-update-script,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastcrw";
  version = "0.32.0";
  src = fetchFromGitHub {
    owner = "us";
    repo = "crw";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zk8xjKPPifNiHqx/B01ZG3r9xgoG1p1D1M7LhQoHD5Y=";
  };

  cargoHash = "sha256-yVh3B9Xl5yB9YWG0+lDOudnD1qi2VpAWBnItFZiRr3c=";

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
