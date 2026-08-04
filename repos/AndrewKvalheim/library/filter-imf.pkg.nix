{ rustPlatform }:

rustPlatform.buildRustPackage (filter-imf: {
  pname = "filter-imf";
  version = "1.0.1";
  meta = {
    mainProgram = "filter-imf";
  };

  src = fetchGit {
    url = ~/akorg/project/current/filter-imf/filter-imf;
    ref = "v${filter-imf.version}";
  };

  cargoHash = "sha256-x8hXF0p6k80evgjnMy7QCiPb+ybRLnaQz5MslQq6Wzk=";
})
