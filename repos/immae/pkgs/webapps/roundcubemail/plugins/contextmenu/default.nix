{ buildPlugin }:
buildPlugin rec {
  appName = "contextmenu";
  version = "2.3";
  url = "https://github.com/johndoh/roundcube-${appName}/archive/${version}.tar.gz";
  sha256 = "1rb8n821ylfniiiccfskc534vd6rczhk3g82455ks3m09q6l8hif";
}
