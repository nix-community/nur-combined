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
  hash = "sha256-DFsaz23yAiW0dX5WPHlgVGZSv05nDBHNXuY8MN4rUbA=";
  stripRoot = false;
}
