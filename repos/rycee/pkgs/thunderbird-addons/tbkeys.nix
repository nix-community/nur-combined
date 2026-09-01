{
  buildMozillaXpiAddon,
  lib,
  ...
}:

buildMozillaXpiAddon {
  pname = "tbkeys";
  version = "2.4.4";
  addonId = "tbkeys@addons.thunderbird.net";
  url = "https://github.com/wshanks/tbkeys/releases/download/v2.4.4/tbkeys.xpi";
  sha256 = "7330d76f4b6b56cc0eb27fff3f2c0bd4974acba6df8ab631114fc82b3bed0a98";
  meta = with lib; {
    homepage = "https://github.com/wshanks/tbkeys";
    description = "Custom keyboard shortcuts for Thunderbird";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
