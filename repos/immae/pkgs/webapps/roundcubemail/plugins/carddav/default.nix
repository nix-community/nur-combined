{ buildPlugin }:
buildPlugin rec {
  appName = "carddav";
  version = "3.0.3";
  url = "https://github.com/blind-coder/rcmcarddav/releases/download/v${version}/${appName}-${version}.tar.bz2";
  sha256 = "0cf5rnqkhhag2vdy808zfpr4l5586fn43nvcia8ac1ha58azrxal";
}
