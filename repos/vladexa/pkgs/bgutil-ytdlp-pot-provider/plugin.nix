{
  fetchzip,
  meta,
  version,
  ...
}:
fetchzip {
  inherit version meta;
  pname = "bgutil-ytdlp-pot-provider-plugin";
  url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${version}/bgutil-ytdlp-pot-provider.zip";
  hash = "sha256-v4HgNGbC9ZBZoVi66EPjyu5bETD/jSyz/J/5PoTxpzM=";
  stripRoot = false;
}
