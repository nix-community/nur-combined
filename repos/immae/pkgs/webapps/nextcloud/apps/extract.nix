{ buildApp }:
buildApp rec {
  appName = "extract";
  version = "1.2.2";
  url = "https://github.com/PaulLereverend/NextcloudExtract/releases/download/${version}/${appName}.tar.gz";
  sha256 = "1aq8f5ps8259ihlh1qwhcj1gwy6w341gmagzz1r763pipkj960g6";
}
