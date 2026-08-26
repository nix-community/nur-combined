{
  buildMozillaXpiAddon,
  lib,
}:

buildMozillaXpiAddon {
  pname = "soundfixer";
  version = "1.4.1";
  addonId = "soundfixer@unrelenting.technology";
  url = "https://addons.mozilla.org/firefox/downloads/file/4205769/soundfixer-1.4.1.xpi";
  sha256 = "sha256-sinHdjXk6Jq1hhRK6i/Ml3osXlFQmoSsiE+lninud5I=";
  meta = with lib; {
    homepage = "https://github.com/valpackett/soundfixer";
    description = "WebExtension that lets you fix sound problems in e.g. YouTube videos";
    license = licenses.unlicense;
    mozPermissions = [
      "activeTab"
      "webNavigation"
    ];
    platforms = platforms.all;
  };
}
