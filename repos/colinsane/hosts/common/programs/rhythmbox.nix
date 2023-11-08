{ ... }:
{
  sane.programs.rhythmbox = {
    persist.byStore.plaintext = [
      # playlists; index
      ".local/share/rhythmbox"
      # album art
      ".cache/rhythmbox"
    ];
  };
}
