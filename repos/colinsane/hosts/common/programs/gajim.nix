{ ... }:
{
  sane.programs.gajim = {
    persist.private = [
      # avatars, thumbnails...
      ".cache/gajim"
      # sqlite database labeled "settings". definitely includes UI theming
      ".config/gajim"
      # omemo keys, downloads, logs
      ".local/share/gajim"
    ];
  };
}
