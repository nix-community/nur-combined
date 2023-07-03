{ ... }:
{
  sane.programs.epiphany = {
    persist.private = [
      ".cache/epiphany"
      ".local/share/epiphany"
      # also .config/epiphany, but appears empty
    ];
  };
}
