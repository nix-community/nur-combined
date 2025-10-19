{
  lib,
  pins,
  buildGoModule,
}:
buildGoModule rec {
  pname = "firefox-history-merger";
  version = "unstable-2021-11-05";

  src = pins.firefox-history-merger.outPath;

  vendorHash = "sha256-MSGoJk/UwqkN9mqL4hBlP4DsVcFR2aypcA3ELCmmTxI=";

  meta = with lib; {
    description = "Merge Firefox history and repair missing favicons with ease";
    homepage = "https://github.com/crazy-max/firefox-history-merger";
    maintainers = with maintainers; [ arobyn ];
    platforms = with platforms; linux ++ darwin;
    license = licenses.mit;
  };
}
