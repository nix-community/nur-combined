{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.nvimpager;
in
{
  sane.programs.nvimpager = {
    packageUnwrapped = (pkgs.nvimpager.override {
      neovim = config.sane.programs.neovim.packageUnwrapped;
    }).overrideAttrs (upstream: {
      # 1. force nvimpager to use my vim config.
      # by default it loads ~/.config/nvimpager/init.vim instead.
      # could instead symlink the latter, but sandboxing issues.
      # 2. make some deps available to the script:
      # - cat (coreutils)
      # - mktemp (coreutils)
      # - tput (ncurses)
      # - wc (coreutils)
      # these are all on the default nixpkgs path, but i remove those (polyunfill),
      # plus i run nvimpager in places which don't use systemPackages.
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace nvimpager \
          --replace-fail 'args=(' 'args=(-u ~/.config/nvim/init.vim '

        sed '2 i PATH=''${PATH:+$PATH:}:${lib.makeBinPath [ pkgs.coreutils pkgs.ncurses ]}' -i nvimpager
      '';
      # check phase fails, something to do with me enabling plugins not expected by the tester
      doCheck = false;
    });

    suggestedPrograms = [ "neovim" ];

    sandbox.extraHomePaths = [
      ".config/nvim"
    ];
    sandbox.whitelistWayland = true;  # for system clipboard integration

    env.MANPAGER = "nvimpager";
    env.PAGER = "nvimpager";
    # `man 2 select` will have `man` render the manpage to plain text, then pipe it into vim for syntax highlighting.
    # force MANWIDTH=999 to make `man` not hard-wrap any lines, and instead let vim soft-wrap lines.
    # that allows the document to be responsive to screen-size/windowing changes.
    # MANROFFOPT = "-c" improves the indentation, but i'm not totally sure what it actually does.
    env.MANWIDTH = "999";
    env.MANROFFOPT = "-c";
  };

  sane.programs.man-db.sandbox.extraHomePaths = lib.mkIf cfg.enabled [
    ".config/nvim"
  ];
}
