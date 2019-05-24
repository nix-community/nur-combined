{ buildApp }:
buildApp rec {
  appName = "music";
  version = "0.9.5";
  url = "https://github.com/owncloud/${appName}/archive/v${version}.tar.gz";
  sha256 = "0dx136z7anmi18harc1v2hyfdaq568lqf3wpy9hgx309ggb4wwzx";
}
