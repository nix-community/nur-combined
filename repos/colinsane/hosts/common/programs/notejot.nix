{ ... }:
{
  sane.programs.notejot = {
    sandbox.whitelistWayland = true;
    sandbox.whitelistDri = true;  #< otherwise intolerably slow on moby
    gsettingsPersist = [ "io/github/lainsce/Notejot" ];  #< TODO: probably not needed

    sandbox.mesaCacheDir = ".cache/io.github.lainsce.Notejot/mesa";
    persist.byStore.private = [
      ".local/share/io.github.lainsce.Notejot"
    ];
  };
}
