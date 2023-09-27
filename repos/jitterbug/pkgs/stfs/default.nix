{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  version = "8f2e83c3828b9cb9891766f31b695d5f80c63e75";
in
buildGoModule {
  inherit version;
  pname = "stfs";

  src = fetchFromGitHub {
    rev = version;
    owner = "pojntfx";
    repo = "stfs";
    sha256 = "sha256-qX7f1GegpWHVpVqmqHunXeFt1tQZU0vihMkEz2k/NZc=";
  };

  vendorHash = "sha256-zynSreuSMOn8oGbilLbATyHDz9NmgxLWsE3FAKYqzeU=";
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
