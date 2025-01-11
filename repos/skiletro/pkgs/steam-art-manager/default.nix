{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 {
  pname = "steam-art-manager";
  version = "3.10.6";
  src = fetchurl {
    url = "https://github.com/Tormak9970/Steam-Art-Manager/releases/download/v3.10.6/steam-art-manager.AppImage";
    sha256 = "sha256-1u/UhHaD3vfPlGHbQG6Kv51vXBGcMHASHq7d7/G6Cbk=";
  };
  meta.description = "Simple and elegant Steam library customization";
}
