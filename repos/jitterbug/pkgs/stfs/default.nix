{
  lib,
  buildGoModule,
  fetchFromGitHub,
  maintainers,
  ...
}:
let
  pname = "stfs";
  version = "0.1.1";

  rev = "v${version}";
  hash = "sha256-2dl7VK3mwasusNLiLfNVNjaNSEKo+eKyFwOwUDL9RzA=";
  vendorHash = "sha256-uyW1k5pJpSOlVJ6bDxEM/nQYGdrw0Inbdh4PGgNl5go=";
in
buildGoModule {
  inherit pname version vendorHash;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "pojntfx";
    repo = "stfs";
  };

  doCheck = false;

  meta = {
    inherit maintainers;
    description = "Simple Tape File System (STFS), a file system for tapes and tar files.";
    homepage = "https://github.com/pojntfx/stfs";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
