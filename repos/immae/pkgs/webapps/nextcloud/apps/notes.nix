{ buildApp }:
buildApp rec {
  appName = "notes";
  version = "2.6.0";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1b1vc8plv4mpsxl7mgwgrcrswphclsm9xa89vxf3s4xzlwwq11c4";
}
