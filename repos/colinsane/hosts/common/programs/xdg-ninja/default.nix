# xdg-ninja: locates $HOME-based dotfiles and instructs how to move them to a proper XDG home.
{ ... }:
{
  sane.programs.xdg-ninja = {
    sandbox.extraHomePaths = [
      "/"
    ];
  };
}
