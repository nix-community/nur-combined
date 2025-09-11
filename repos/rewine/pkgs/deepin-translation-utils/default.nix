{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "deepin-translation-utils";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-translation-utils";
    rev = version;
    hash = "sha256-FxSU753m0+7UzIKPKm4Swn12IBfnzPVsdKPtiAjAH+E=";
  };

  cargoHash = "sha256-Kne2GXtsDGWyCExX6yC3pdSmsp0XHeEiPUrf/pWleeo=";

  meta = {
    description = "A commandline tool to help you work with translation files and Transifex configurations that are used in deepin's workflow";
    homepage = "https://github.com/linuxdeepin/deepin-translation-utils.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "deepin-translation-utils";
  };
}
