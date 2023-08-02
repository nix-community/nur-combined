{ pkgs, ... }:
{
  sane.programs.fractal = {
    # package = pkgs.fractal-latest;
    package = pkgs.fractal-next;

    # XXX by default fractal stores its state in ~/.local/share/stable/<UUID>.
    persist.private = [ ".local/share/stable" ];
  };
}
