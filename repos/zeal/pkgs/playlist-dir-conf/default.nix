{
  lib,
  fetchFromGitHub,
  unstableGitUpdater,
  mpvScripts,
}:
mpvScripts.buildLua {
  pname = "playlist-dir-conf";
  version = "0-unstable-2026-05-31";
  src = fetchFromGitHub {
    owner = "zzzealed";
    repo = "mpv-playlist-dir-conf";
    rev = "2f6f1678a05c923cc0ce83ab1d4e2ead54baa179";
    hash = "sha256-WxCwRWQcRnvLiIpc9g9cAfBn2VVvRwhriAGGWDaO0rU=";
  };
  passthru.updateScript = unstableGitUpdater { };
  meta = {
    description = "MPV script that loads a config from a playlists directory";
    longDescription = "MPV script that loads a mpv.conf from the directory of the playlist, extending `--use-filedir-conf` behavior to work with playlists";
    homepage = "https://github.com/zzzealed/mpv-playlist-dir-conf";
    license = lib.licenses.agpl3Only;
  };
}
