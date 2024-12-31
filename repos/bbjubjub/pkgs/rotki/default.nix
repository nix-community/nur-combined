{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "rotki";
  version = "v1.37.0";
  src = fetchurl {
    url = "https://github.com/rotki/rotki/releases/download/${version}/rotki-linux_x86_64-${version}.AppImage";
    hash = "sha256-zgk6TaOn6APC7BYCK8/JMVnvj3K/0vrEOZzQjjHLyi4=";
  };

  meta.platforms = [ "x86_64-linux" ];
}
