{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "osm-lump-ways";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "amandasaurus";
    repo = "osm-lump-ways";
    tag = "v${finalAttrs.version}";
    hash = "sha256-37DdtTPnzmfIjfTiQhOJwq7ieMTpKiOpmEJG7UXaxQo=";
  };

  cargoHash = "sha256-JqHm2oKWFuHrayU5pnDxrrfbi84tmMecRDCrq7fQFuw=";

  meta = {
    description = "Group OSM ways together based on topology & tags";
    homepage = "https://github.com/amandasaurus/osm-lump-ways";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
  };
})
