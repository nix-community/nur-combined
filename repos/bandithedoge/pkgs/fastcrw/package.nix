{
  sources,

  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.fastcrw) pname src;
  version = lib.removePrefix "v" sources.fastcrw.version;
  cargoLock = sources.fastcrw.cargoLock."Cargo.lock";

  checkFlags = [
    "--skip="
    "sitemap::tests::fetch_sitemap*"
  ];

  meta = {
    description = "Fast, lightweight Firecrawl alternative in Rust";
    homepage = "https://fastcrw.com";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "crw";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
