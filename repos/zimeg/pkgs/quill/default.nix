{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "quill";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "anchore";
    repo = "quill";
    rev = "refs/tags/v${version}";
    hash = "sha256-Tthhhc7moLj4YRlZdV5Q7NAWUKyDLkSdYi4gXT2iFbI=";
  };

  vendorHash = "sha256-hlLSa7NE2YzgAZYys8kYE/wlTtFK+NUa1z9Cly121iI=";

  ldflags = [
    "-s"
    "-w"
  ];

  checkPhase = '''';

  meta = {
    description = "Simple mac binary signing from any platform";
    homepage = "https://github.com/anchore/quill";
    changelog = "https://github.com/anchore/quill/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainPrograms = "quill";
  };
}
