{ pkgs, ... }:
{
  sane.programs.megapixels.package = pkgs.megapixels.override {
    # megapixels uses zbar to read barcodes.
    # zbar by default ships zbarcam-gtk and zbarcam-qt, neither of which megapixels needs.
    # but the latter takes a dep on qt, which bloats the closure and the build, so disable this feature.
    zbar = pkgs.zbar.override {
      enableVideo = false;
    };
  };
}
