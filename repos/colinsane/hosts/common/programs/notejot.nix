{ ... }:
{
  sane.programs.notejot = {
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;
    sandbox.whitelistDri = true;  #< otherwise intolerably slow on moby
    sandbox.extraHomePaths = [ ".config/dconf" ];  #< for legacy notes (moby), loaded via dconf
    suggestedPrograms = [ "dconf" ];  #< else it can't persist notes

    persist.byStore.private = [
      ".local/share/io.github.lainsce.Notejot"
    ];
  };
}
