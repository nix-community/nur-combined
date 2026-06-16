# <https://github.com/hpjansson/chafa>
# `chafa FILE.png` to render an image to the terminal
# `chafa -f sixel FILE.png` to render it using sixel API
{ ... }:
{
  sane.programs.chafa = {
    sandbox.autodetectCliPaths = "existing";
  };
}
