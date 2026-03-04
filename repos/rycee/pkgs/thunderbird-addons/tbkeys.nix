{
  buildMozillaXpiAddon,
  lib,
  ...
}:

buildMozillaXpiAddon {
  pname = "tbkeys";
  version = "2.4.3";
  addonId = "tbkeys@addons.thunderbird.net";
  url = "https://github.com/wshanks/tbkeys/releases/download/v2.4.3/tbkeys.xpi";
  sha256 = "d9ef93e4daf991cdacf04ca417358a6896768cf5031e1f42aa7e210ae0c22da3";
  meta = with lib; {
    homepage = "https://github.com/wshanks/tbkeys";
    description = "Custom keyboard shortcuts for Thunderbird";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
