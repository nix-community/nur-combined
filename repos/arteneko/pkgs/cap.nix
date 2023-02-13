{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.3.1";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v${version}";
    sha256 = "1kyq7w92ik8wkqcfbb9bixj3byc878qvd7crrgiarhrxgvajdsy5";
  };

  vendorHash = "sha256-ZCRydD/X+yxXZIofeq/yxREKnvuqkQznRkkELpTOcF0=";

  meta = with lib; {
    description = "a simple to use website builder that's meant to be easy to use by default";
    homepage = "https://git.sr.ht/~artemis/cap";
    license = licenses.free;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
