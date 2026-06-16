{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "sheets";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "sheets";
    rev = "v${version}";
    hash = "sha256-sRJ1rqtxc4axAkVavxSR2afdvxCAjJdK2mBWnt+nzW0=";
  };

  vendorHash = "sha256-WWtAt0+W/ewLNuNgrqrgho5emntw3rZL9JTTbNo4GsI=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  meta = with lib; {
    description = "A terminal spreadsheet editor with vim-like keybindings.";
    homepage = "https://github.com/maaslalani/sheets";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "sheets";
  };
}
