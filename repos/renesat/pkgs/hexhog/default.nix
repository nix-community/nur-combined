{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "hexhog";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "DVDTSB";
    repo = "hexhog";
    tag = "v${version}";
    hash = "sha256-DbZZ/8OC29PQu539csKygMWf9IT/laNiFKoEV5GIU/0=";
  };

  cargoHash = "sha256-CSEJLPhIJDqVscL7ETM+a1CV2sjaaqGQg/fpU+M0I0g=";

  meta = {
    description = "A configurable hex viewer/editor";
    homepage = "https://github.com/DVDTSB/hexhog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
  };
}
