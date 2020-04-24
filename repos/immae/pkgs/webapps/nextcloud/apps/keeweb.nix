{ buildApp }:
buildApp rec {
  appName = "keeweb";
  version = "0.5.1";
  url = "https://github.com/jhass/nextcloud-keeweb/releases/download/v${version}/${appName}-${version}.tar.gz";
  sha256 = "1iaz4d6fz4zlgdn2hj7xx0nayyd0l865zxd6h795fpx5qpdj911h";
  installPhase = ''
    mkdir -p $out
    cp -R . $out/
    '';
  otherConfig = {
    mimetypemapping = {
      "kdbx" = ["application/x-kdbx"];
    };
  };
}
