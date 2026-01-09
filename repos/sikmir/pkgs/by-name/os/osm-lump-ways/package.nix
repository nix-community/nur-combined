{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "osm-lump-ways";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "amandasaurus";
    repo = "osm-lump-ways";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2ZQtr7VPamA063N2i4kGHjcvaFDI/2AA2J0Rj/RwA3o=";
  };

  cargoHash = "sha256-K8usoAES2mtys54hQlLqB0SrW0/f+235hdcLTiQxZKY=";

  checkFlags = [
    "--skip=get_two_muts::test::test5"
  ];

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
