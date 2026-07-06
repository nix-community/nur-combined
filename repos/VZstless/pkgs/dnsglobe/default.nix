{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dnsglobe";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "514-labs";
    repo = "dnsglobe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hs5oj5nl4dH4nLCtarZbdeRMyLoOqPpnNtnPpTZLrpA=";
  };

  cargoHash = "sha256-gUVGUkJW5KwJd7rFi6C/4hj2pjChGvKLQNQjQwX3zsg=";

  meta = {
    description = "ELF visualizer, generates HTML files from ELF binaries";
    homepage = "https://github.com/514-labs/dnsglobe";
    license = lib.licenses.mit;
    mainProgram = "dnsglobe";
  };
})
