{ buildApp }:
buildApp rec {
  appName = "ocsms";
  version = "2.1.1";
  url = "https://github.com/nextcloud/${appName}/releases/download/${version}/${appName}-${version}.tar.gz";
  sha256 = "0sgfbmy1c8rgzjvf9snc7rzgp8aqsc65zfwgi6qcsf2g6gam5n7a";
  installPhase = ''
    sed -i -e "/addScript.*devel/d" -e "s@//\(.*addScript.*app.min\)@\1@" templates/main.php
    sed -i -e 's/max-version="15.0"/max-version="16.0"/' appinfo/info.xml
    mkdir -p $out
    cp -R . $out/
    '';
}
