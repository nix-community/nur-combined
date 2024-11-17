# chat: <https://mopidy.zulipchat.com/>
# config docs: <https://docs.mopidy.com/en/latest/config/>
# web client: <http://localhost:6680>
# mpd: hosted on `localhost:6600`, no password`
#
# dump config:
# - `mopidy config`
# update local file index with
# - `mopidy local scan`
#
# if running as service, those commands are `mopidy --config ... <command>`
# and config path is found by `systemctl cat mopidy`
{ config, lib, pkgs, ... }:

let
  # TODO: upstream this as `mopidy.withExtensions`
  # this is borrowed from the nixos mopidy service
  mopidyWithExtensions = extensions: with pkgs; buildEnv {
    name = "mopidy-with-extensions-${mopidy.version}";

    paths = lib.closePropagation extensions;
    pathsToLink = [ "/${mopidyPackages.python.sitePackages}" ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      makeWrapper ${lib.getExe mopidy} $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${mopidyPackages.python.sitePackages}
    '';
  };
in
{
  sane.programs.mopidy = {
    packageUnwrapped = mopidyWithExtensions (with pkgs; [
      mopidy-iris  # web client: <https://github.com/jaedb/Iris>
      mopidy-jellyfin
      mopidy-local
      mopidy-mpd
      mopidy-mpris
      mopidy-spotify
      # TODO: mopidy-podcast, mopidy-youtube

      # alternate web clients:
      # mopidy-moped: <https://github.com/martijnboland/moped>
      # mopidy-muse: <https://github.com/cristianpb/muse>
    ]);
    persist.byStore.plaintext = [
      ".local/share/mopidy/local"  # thumbs, library db
    ];
    persist.byStore.private = [
      ".local/share/mopidy/http"  # cookie
    ];
    secrets.".config/mopidy/mopidy.conf" = ../../../secrets/common/mopidy.conf.bin;
    # other folders:
    # - .cache/mopidy
    # - .config/mopidy
  };
}
