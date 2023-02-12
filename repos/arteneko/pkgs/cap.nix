{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "cap";
  version = "0.2.0";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "cap";
    rev = "v${version}";
    sha256 = "09fjrwcsnwdvylzrq07z86dhndvak8y8ba3y7z2q2jlfyima0gja";
  };

  vendorHash = "sha256-ZCRydD/X+yxXZIofeq/yxREKnvuqkQznRkkELpTOcF0=";

  meta = with lib; {
    description = "a simple to use website builder that's meant to be easy to use by default";
    homepage = "https://git.sr.ht/~artemis/cap";
    license = licenses.free;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
