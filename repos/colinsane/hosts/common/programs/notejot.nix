{ ... }:
{
  sane.programs.notejot = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistWayland = true;
    suggestedPrograms = [ "dconf" ];  #< else it can't persist notes

    persist.byStore.private = [
      ".local/share/io.github.lainsce.Notejot"
    ];
  };
}
