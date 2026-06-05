# cantata is a mpd frontend.
# before launching it, run `mopidy` in some tab
# TODO: auto-launch mopidy when cantata launches?
{ ... }:
{
  sane.programs.cantata = {
    persist.byStore.plaintext = [
      ".cache/cantata"  # album art
      ".local/share/cantata/library"  # library index (?)
    ];
    fs.".config/cantata/cantata.conf".symlink.text = ''
      [General]
      fetchCovers=true
      storeCoversInMpdDir=false
      version=2.5.0

      [Connection]
      allowLocalStreaming=true
      applyReplayGain=true
      autoUpdate=false
      dir=~/Music
      host=localhost
      partition=
      passwd=
      port=6600
      replayGain=off
      streamUrl=

      [LibraryPage]
      artist\gridZoom=100
      artist\searchActive=false
      artist\viewMode=detailedtree
    '';
    suggestedPrograms = [ "mopidy" ];
  };
}
