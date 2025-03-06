{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tantivy-go";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IlGtyTjOAvmrbgmvy4NelTOgOWopxNta3INq2QcMEqY=";
  };

  sourceRoot = "${finalAttrs.src.name}/rust";

  useFetchCargoVendor = true;
  cargoPatches = [ ./Cargo.lock.patch ];
  cargoHash = "sha256-nwSk9csAz5tCxrgFEOf2EBXei3nSL+06xLCAOhFpwxs=";

  postPatch = ''
    chmod +w ../bindings.h
  '';

  meta = with lib; {
    description = "Tantivy go bindings";
    homepage = "https://github.com/anyproto/tantivy-go";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
})
