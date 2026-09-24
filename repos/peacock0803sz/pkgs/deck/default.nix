{ lib, buildGo126Module, fetchFromGitHub }:
# https://github.com/k1LoW/deck
let
  version = "1.24.1";
  pname = "deck";
in
buildGo126Module {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-uLuVHgI0Mp6d3ZZoKK6I+Hcg3uQ0iYUle1E0exbf2h4=";
  };

  vendorHash = "sha256-0dEg9NtTU9NjJnuBlGH6lfM/AXFCi/kXXC2Xm66LKwY=";

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
