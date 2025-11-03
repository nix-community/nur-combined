{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mdbook-generate-summary";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "younata";
    repo = "mdbook-generate-summary";
    rev = "v${version}";
    hash = "sha256-2+6jCrfVhbBKihO4XvEWCF5vR5298TEVgNUPSeHnwmg=";
  };

  cargoHash = "sha256-MKxhPvMyEQvpZs5dkaykz3YOTvuUoHQGFgngvcGBHfg=";

  meta = with lib; {
    description = "A tool to automatically generate mdBook SUMMARY.md files";
    homepage = "https://github.com/younata/mdbook-generate-summary";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "mdbook-generate-summary";
  };
}
