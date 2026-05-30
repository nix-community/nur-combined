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
    rev = "a4ac6866acfee6d53863811871754377100825d7";
    hash = "sha256-0ESkiYZfjvNxzUnBaqmQJPMbodLEkNwki8efnSDUHcQ=";
  };
  passthru.updateScript = unstableGitUpdater { };
  meta = {
    description = "MPV script that loads a config from a playlists directory";
    longDescription = "MPV script that loads a mpv.conf from the directory of the playlist, extending `--use-filedir-conf` behavior to work with playlists";
    homepage = "https://github.com/zzzealed/mpv-playlist-dir-conf";
    license = lib.licenses.agpl3Only;
  };
}
