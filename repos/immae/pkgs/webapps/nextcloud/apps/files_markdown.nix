{ buildApp }:
buildApp rec {
  appName = "files_markdown";
  version = "2.0.6";
  url = "https://github.com/icewind1991/${appName}/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1ng8gpjl3g1141k1nii59cg005viidlcbsg4x9brzcj25c5qhjjp";
}
