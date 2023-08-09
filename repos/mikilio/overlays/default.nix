{ pkgs ? {} }: {
  /*
    In nixpkgs vimPlugins is an overridable, recursive attribute set.
    This means it can be extended like so:

    myVimPlugins = pkgs.vimPlugins.extend config.nur.repo.mikilio.vimPlugins;

    This overlay is intended for this use-case only and alternative use is not supported.
    The decision to provide vimPlugins as an overlay is to enable seamless integration
    with other plugins.

    See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/doc/languages-frameworks/vim.section.md#vim-out-of-tree-overlays
  */
  vimPlugins = pkgs.callPackage ./vimPlugins {};
  thunar = import ./thunar;
}
