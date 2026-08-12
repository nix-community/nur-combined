{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gon";
  version = "0.0.37";

  src = fetchFromGitHub {
    owner = "Bearer";
    repo = "gon";
    rev = "refs/tags/v${version}";
    hash = "sha256-Sz+ljBaluN0vONpNpudwEiEKQtoeB71kQfIqjcnXN9c=";
  };

  subPackages = [ "cmd/gon" ];
  deleteVendor = true;
  vendorHash = "sha256-wJaNU0CYLktFKjMefZT0cPNawl0Du/P3H3algqERLqY=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Sign, notarize, and package macOS CLI tools and applications written in any language.";
    mainProgram = "gon";
    homepage = "https://github.com/Bearer/gon";
    changelog = "https://github.com/Bearer/gon/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
