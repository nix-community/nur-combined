{ ... }:
{
  sane.programs.notejot = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/dconf"  # else it can't persist notebooks
    ];

    persist.byStore.private = [
      ".local/share/io.github.lainsce.Notejot"
    ];
  };
}
