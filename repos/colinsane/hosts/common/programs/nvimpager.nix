{ config, pkgs, ... }:
{
  sane.programs.nvimpager = {
    packageUnwrapped = (pkgs.nvimpager.override {
      neovim = config.sane.programs.neovim.packageUnwrapped;
    }).overrideAttrs {
      # check phase fails, something to do with me enabling plugins not expected by the tester
      doCheck = false;
    };

    suggestedPrograms = [ "neovim" ];

    sandbox.whitelistWayland = true;  # for system clipboard integration

    env.MANPAGER = "nvimpager";
    # env.PAGER = "nvimpager";
    # `man 2 select` will have `man` render the manpage to plain text, then pipe it into vim for syntax highlighting.
    # force MANWIDTH=999 to make `man` not hard-wrap any lines, and instead let vim soft-wrap lines.
    # that allows the document to be responsive to screen-size/windowing changes.
    # MANROFFOPT = "-c" improves the indentation, but i'm not totally sure what it actually does.
    env.MANWIDTH = "999";
    env.MANROFFOPT = "-c";
  };
}
