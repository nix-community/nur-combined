{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.3.5";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v${version}";
    hash = "sha256-8OCHcIljyo50Tx3hBP21ELXtcmzrAH8MR7XLTo0GwNo=";
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
