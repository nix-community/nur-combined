{ lib, vscode-utils }:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in

{
  randomfractalsinc.geo-data-viewer = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "geo-data-viewer";
      publisher = "randomfractalsinc";
      version = "2.4.0";
      sha256 = "sha256-r8gdiHdXepCwy5nM8v50qRehYHy/rnfXDPzP8CNI3H8=";
    };
    meta = with lib; {
      license = licenses.asl20;
      maintainers = [ maintainers.sikmir ];
    };
  };

  sonarsource.sonarlint-vscode = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "sonarlint-vscode";
      publisher = "SonarSource";
      version = "3.5.4";
      sha256 = "sha256-AXUrduYJ9CEZL41XAUu2Flgn5URoUqOuUEIXv1nwXU0=";
    };
    meta = with lib; {
      license = licenses.gpl3;
      maintainers = [ maintainers.sikmir ];
    };
  };
}
