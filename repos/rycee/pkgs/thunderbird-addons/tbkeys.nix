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
  sha256 = "4399ba8eb915377534c786c66b32cc79c811747e6e67f08061837a53bb44df81";
  meta = with lib; {
    homepage = "https://github.com/wshanks/tbkeys";
    description = "Custom keyboard shortcuts for Thunderbird";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
