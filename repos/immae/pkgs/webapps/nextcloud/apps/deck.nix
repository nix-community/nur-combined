{ buildApp }:
buildApp rec {
  appName = "deck";
  version = "0.6.1";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1hafgj67zbhs4higf7nyr61p4s31axzxrsq09c4wmcwviz7p7zvs";
}
