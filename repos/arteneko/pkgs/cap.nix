{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.4.0";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v0.4.0";
    hash = "sha256-yrfUQDA5A5j3WNhvnvGuPZCCS5lcTdpo+QxAxQntz7s=";
  };

  vendorHash = "sha256-ciEfRHL08Fo8gPs/jQUDcrLd6DvqFjFrEtoekVRpXPU=";

  ldflags = [
    "-X main.BuildVersion=${version}"
  ];

  meta = with lib; {
    description = "a simple to use website builder that's meant to be easy to use by default";
    homepage = "https://git.sr.ht/~artemis/cap";
    license = licenses.free;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
