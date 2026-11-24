{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "toml-schema-rust";
  version = "1.0.0-rc.2";
  src = fetchFromGitHub {
    owner = "brunoborges";
    repo = "toml-schema";
    rev = "v${version}";
    hash = "sha256-G/L0iZp+aRm+BpZlk7CiRc8ipDV9vboM+P+hctNX6zI=";
  };
  sourceRoot = "${src.name}/reference-implementations/rust";
  cargoHash = "sha256-2+O1y+iSVJMyvLzVpPMvYBl3+HRAbDP0Bbv2wglnt7g=";
}
