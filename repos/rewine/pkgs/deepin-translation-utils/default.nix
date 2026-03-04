{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "deepin-translation-utils";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-translation-utils";
    rev = version;
    hash = "sha256-JavdbR3w1k/TPJrPnTHuEDDAbch1s4CvB/1xlzjVQZc=";
  };

  cargoHash = "sha256-JsqWrU3g2MpTK7ICRiOtXbPcu3nUDH3CFGpFmWwLaR8=";

  meta = {
    description = "A commandline tool to help you work with translation files and Transifex configurations that are used in deepin's workflow";
    homepage = "https://github.com/linuxdeepin/deepin-translation-utils.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "deepin-translation-utils";
  };
}
