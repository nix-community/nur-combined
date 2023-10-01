{ pkgs, ... }:
{
  sane.programs.fractal = {
    package = pkgs.fractal-latest;
    # package = pkgs.fractal-next;

    persist.private = [
      # XXX by default fractal stores its state in ~/.local/share/<build-profile>/<UUID>.
      ".local/share/hack"    # for debug-like builds
      ".local/share/stable"  # for normal releases
    ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
