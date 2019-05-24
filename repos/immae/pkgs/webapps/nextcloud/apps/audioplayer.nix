{ buildApp }:
buildApp rec {
  appName = "audioplayer";
  version = "2.7.0";
  url = "https://github.com/Rello/${appName}/releases/download/${version}/${appName}-${version}.tar.gz";
  sha256 = "05dylw45hs32agy6wqjy4r2x3h1dxzyzn0378ig6h5a22xd52mik";
}
