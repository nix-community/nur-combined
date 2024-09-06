{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  version = "v0.1.1";
in
buildGoModule {
  inherit version;
  pname = "stfs";

  src = fetchFromGitHub {
    rev = version;
    owner = "pojntfx";
    repo = "stfs";
    sha256 = "sha256-2dl7VK3mwasusNLiLfNVNjaNSEKo+eKyFwOwUDL9RzA=";
  };

  vendorHash = "sha256-uyW1k5pJpSOlVJ6bDxEM/nQYGdrw0Inbdh4PGgNl5go=";
  doCheck = false;

  meta = with lib; {
    description = "Simple Tape File System (STFS), a file system for tapes and tar files.";
    homepage = "https://github.com/pojntfx/stfs";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://github.com/pojntfx/stfs";
  };
}
