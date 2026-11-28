{
  inotify-tools,
  ncurses,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-dev-cargo-loop";
  srcRoot = ./.;
  packages = {
    inherit
      inotify-tools
      ncurses
      ;
  };
  doInstallCheck = false; # TODO: implement --help flag
}
