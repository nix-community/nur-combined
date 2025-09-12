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
  hash = "sha256-vhF2NfkKfscfjm8A/u+hRuXEA4IvtTTnyaMe+AZA8Ig=";
  stripRoot = false;
}
