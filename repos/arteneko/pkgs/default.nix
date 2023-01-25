self: super:
{
  cap = super.callPackage ./cap.nix {};
  vimPlugins = super.vimPlugins // {
    gls-vim = super.callPackage ./gls-vim.nix {};
  };
}
