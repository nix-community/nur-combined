# plugins: <https://github.com/michaelbrusegard/awesome-wezterm>
#
# TODO: plugin to make <repo:...> URI scheme clickable
{ ... }:
{
  sane.programs.wezterm = {
    sandbox.method = null;  #< TODO: enable sandboxing

    fs.".config/wezterm/wezterm.lua".symlink.target = ./wezterm.lua;
  };
}
