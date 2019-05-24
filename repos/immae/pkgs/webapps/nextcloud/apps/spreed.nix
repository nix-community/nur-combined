{ buildApp }:
buildApp rec {
  appName = "spreed";
  version = "6.0.0";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}-${version}.tar.gz";
  sha256 = "14rcskp4pdcf0g816cdp070c8pzrj33fg2w7jb3af8maf1d77306";
}
