{ ... }:
{
  sane.programs.rhythmbox = {
    persist.plaintext = [
      # playlists; index
      ".local/share/rhythmbox"
      # album art
      ".cache/rhythmbox"
    ];
  };
}
