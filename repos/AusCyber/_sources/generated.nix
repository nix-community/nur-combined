# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  zen-browser = {
    pname = "zen-browser";
    version = "1.13.2b";
    src = fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/1.13.2b/zen.macos-universal.dmg";
      sha256 = "sha256-6u6vGta8cvnC0oKd8Aq6scAyHGRqi39cKBDzpifBOa8=";
    };
  };
  zen-browser-twilight = {
    pname = "zen-browser-twilight";
    version = "1.13.2b";
    src = fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/twilight/zen.macos-universal.dmg";
      sha256 = "sha256-QhklWx4wbwLVfD9CgOlmGAH+zKwH+kkVs/xzHvj3iNA=";
    };
  };
}
