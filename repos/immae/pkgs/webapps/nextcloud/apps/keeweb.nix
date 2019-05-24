{ buildApp }:
buildApp rec {
  appName = "keeweb";
  version = "0.5.0";
  url = "https://github.com/jhass/nextcloud-keeweb/releases/download/v${version}/${appName}-${version}.tar.gz";
  sha256 = "0wdr6ywlirmac7w1ld5ma7fwb4bykclbxfq2sxwg6pvzfid5vc8x";
  installPhase = ''
    mkdir -p $out
    cp -R . $out/
    sed -i -e 's/max-version="15"/max-version="16"/' $out/appinfo/info.xml
    '';
  otherConfig = {
    mimetypealiases = {
      "x-application/kdbx" = "kdbx";
    };
    mimetypemapping = {
      "kdbx" = ["x-application/kdbx"];
    };
  };
}
