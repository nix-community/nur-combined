{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "get-lrc";
  version = "0.02";

  src = fetchFromGitHub {
    owner = "MarsSwimmer";
    repo = "get_lrc";
    rev = version;
    hash = "sha256-GRILMCDm9GUDQI0d/q9AFlnQitH3olKyBXny2yxwDaU=";
  };

  vendorHash = "sha256-3xFoJbbIbBY+vxhjipEqC7k33OnKPkyCRe2Dy4qZE0Y=";

  meta = {
    description = "Show current lrc of Music Player such as Yesplaymusic and LXMusic on status bar for Ubuntu gnome";
    homepage = "https://github.com/MarsSwimmer/get_lrc";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Cryolitia ];
    mainProgram = "get_lrc";
  };
}
