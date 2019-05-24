{ buildApp }:
buildApp rec {
  appName = "bookmarks";
  version = "1.0.2";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}-${version}.tar.gz";
  sha256 = "1ph123d0pram9a0vq73rn0zw0pyg4l0xqg162b59ds68179m2jfp";
}
