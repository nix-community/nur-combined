{ buildApp }:
buildApp rec {
  appName = "maps";
  version = "0.1.2";
  url = "https://github.com/nextcloud/maps/releases/download/v${version}/${appName}-${version}.tar.gz";
  sha256 = "0jk4fikk72g2yj3p0f8i80d26lsi88kfpflrmh5c4acgf3jzxp02";
}
