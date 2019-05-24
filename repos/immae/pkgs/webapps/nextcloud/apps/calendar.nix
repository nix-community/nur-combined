{ buildApp }:
buildApp rec {
  appName = "calendar";
  version = "1.7.0";
  url = "https://github.com/nextcloud/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "0cgvvgzc2kgs2ng36hzff8rrpw9n58f0hyrr41n3wjkf0iynm56r";
}
