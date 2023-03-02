{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.3.4";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v${version}";
    sha256 = "0gckkzqsrvkhqm9zl675n1s83r2rbqs2v16gpyw0pshllym9ny9h";
  };

  vendorHash = "sha256-ZCRydD/X+yxXZIofeq/yxREKnvuqkQznRkkELpTOcF0=";

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
