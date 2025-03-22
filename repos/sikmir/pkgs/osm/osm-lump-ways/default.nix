{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "osm-lump-ways";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "amandasaurus";
    repo = "osm-lump-ways";
    tag = "v${version}";
    hash = "sha256-gHGszPt3rgzm3Q4T3nSBE6y92ovBxa7AUDHvF6/UAE4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-nskIJ4dOih2OsDlGOhL1xTsMwcwY8H8Z32hQZmzgazM=";

  meta = {
    description = "Group OSM ways together based on topology & tags";
    homepage = "https://github.com/amandasaurus/osm-lump-ways";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
  };
}
