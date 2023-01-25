{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.1.7";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v${version}";
    sha256 = "sha256-s7uJVNXvgd5eJ9L6bhtAsgZ5rEvrXeoK/1u9aMSRQxc=";
  };

  vendorHash = "sha256-xfWYUBP8puiiNeNOcDIy2SLMZkHVm358B6q+l3LMhsY=";

  meta = with lib; {
    description = "a simple to use website builder that's meant to be easy to use by default";
    homepage = "https://git.sr.ht/~artemis/cap";
    license = licenses.free;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
