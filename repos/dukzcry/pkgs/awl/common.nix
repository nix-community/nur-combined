{ fetchFromGitHub, fetchFromGitLab, flutter, lib }:

rec {
  version = "2024-05-31";

  src = fetchFromGitLab {
    owner = "repos-holder";
    repo = "awl";
    rev = "2c436fc7737bfdd8be0be5ad8e07c3670b4956d2";
    sha256 = "sha256-QrvYq/OKU5YRDuaYyDSilAhCMQJKoARVd3Gq7GADILM=";
  };
 awl_flutter = (flutter.buildFlutterApplication rec {
    pname = "awl-flutter";
    version = "2023-12-20";

    src = fetchFromGitHub {
      owner = "anywherelan";
      repo = pname;
      rev = "62423b7a4ed48e7522ea356fec17ddfa0dfaaed3";
      sha256 = "sha256-YwlZI2CYSrRUzlkpHlX6Mophzqy0F7A8vWb8+HgzK3w=";
    };

    pubspecLock = lib.importJSON ./pubspec.lock.json;

    targetFlutterPlatform = "web";
  });
}
