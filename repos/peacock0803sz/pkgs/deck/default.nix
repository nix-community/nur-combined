{ lib, buildGo125Module, fetchFromGitHub }:
# https://github.com/k1LoW/deck
let
  version = "1.23.0";
  pname = "deck";
in
buildGo125Module {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-7sDj96aVUvpNgv/gPdc0qUQioYe80tnS95ivyCKjqbY=";
  };

  vendorHash = "sha256-/8N10uxIH+tyw36Fi4wLu381Cebahm3BesLNCalGfAc=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/k1LoW/${pname}/version/version.Version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "deck is a tool for creating deck using Markdown and Google Slides.";
    homepage = "https://github.com/k1LoW/deck";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "gwq";
  };
}
