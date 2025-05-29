{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tantivy-go";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uOL/waiZKei4f+pRz9i5OowWIT9FJ+gQWgHlANjSQII=";
  };

  sourceRoot = "${finalAttrs.src.name}/rust";

  useFetchCargoVendor = true;
  cargoPatches = [ ./Cargo.lock.patch ];
  cargoHash = "sha256-CF1UKff+u26pwZHOiuzzWSaqA1vK7Sup3aXxFK08Vvk=";

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
