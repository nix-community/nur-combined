{ lib
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {
  pname = "wlhax";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "dwapp";
    repo = pname;
    rev = "90357bc3cdcf50d9eee10c005ae54545a38ebdb6";
    hash = "sha256-/IOQ/DGyit50EIKpkK3MsvI1N75YCRbb4blRKlL4q6Q=";
  };

  vendorHash = "sha256-+214VlKahlf0BA2ZChUZgzU3RENYsSP6CZoqPeeXxZg=";
  
  meta = with lib; {
    description = "Wayland proxy that monitors and displays various application state";
    homepage = "https://github.com/dwapp/wlhax";
    license = licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.wineee ];
    mainProgram = "wlhax";
  };
}
