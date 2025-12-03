# page is like nvimpager: it uses neovim as the pager.
# - <https://github.com/I60R/page>
# - unlike `nvimpager`, it does not need to load *all* of stdin before rendering.
#
# it picks up neovim strictly from the environment:
# the nix package doesn't attempt to wrap `page` at all.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.page;
  inherit (config.sane.programs.neovim.config) scrollbackMax;
  sandboxPropagated = {
    extraHomePaths = [
      ".config/nvim"
    ];
    whitelistWayland = true;  # for system clipboard integration
  };
in
{
  sane.programs.page = {
    sandbox = sandboxPropagated // {
      # TODO: this fixes behavior when run as root (e.g. `sudo man ls`), but seems excessive??
      # something about the neovim-remote socket under /tmp/neovim-page/socket...
      # tryKeepUsers = true;
      # extraPaths = "/tmp";
      # capabilities = [ "dac_override" "sys_admin" ];
    };

    packageUnwrapped = pkgs.page.overrideAttrs (upstream: {
      # patch to allow paging of very large input
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace src/pager/neovim.rs \
          --replace-fail ' 100000,' ' ${builtins.toString scrollbackMax},'
      '';

      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.makeBinaryWrapper
      ];

      # `-O -3`: echo all output to terminal, non-interactively, if it would fit
      # within the terminal height (minus 3 lines)
      postFixup = (upstream.postFixup or "") + ''
        wrapProgram $out/bin/page \
          --add-flags '-O -3'
      '';
    });

    suggestedPrograms = [ "neovim" ];

    env.MANPAGER = "page";
    env.PAGER = "page";
    # `man 2 select` will have `man` render the manpage to plain text, then pipe it into vim for syntax highlighting.
    # force MANWIDTH=999 to make `man` not hard-wrap any lines, and instead let vim soft-wrap lines.
    # that allows the document to be responsive to screen-size/windowing changes.
    # MANROFFOPT = "-c" improves the indentation, but i'm not totally sure what it actually does.
    env.MANWIDTH = "999";
    env.MANROFFOPT = "-c";
  };

  sane.programs.git.sandbox = lib.mkIf cfg.enabled sandboxPropagated;
  sane.programs.man-db.sandbox = lib.mkIf cfg.enabled sandboxPropagated;
  sane.programs.mercurial.sandbox = lib.mkIf cfg.enabled sandboxPropagated;
}
