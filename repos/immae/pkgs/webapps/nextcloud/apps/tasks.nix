{ buildApp }:
buildApp rec {
  appName = "tasks";
  version = "0.10.1";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "0r888yr6bl2y5mp65q8md5k139as1a0xw4yfzvkv7y77wmqn9wsm";
}
