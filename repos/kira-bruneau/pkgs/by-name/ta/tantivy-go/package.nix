{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tantivy-go";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iTGIm5C7SMBZv2OcKCQCyEZS/eeMJQ5nFSpuFJbTEXU=";
  };

  sourceRoot = "${finalAttrs.src.name}/rust";

  useFetchCargoVendor = true;
  cargoPatches = [ ./Cargo.lock.patch ];
  cargoHash = "sha256-pg2y+LfroFnkEFqfCaiG6tErbPkqg+UKE5RPvdP3A74=";

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
