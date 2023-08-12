# load the web client at:
# - <http://localhost:6680>
# chat:
# - <https://mopidy.zulipchat.com/>
# update local file index with
# - `mopidy --config ... local scan`
# mopidy hosts mpd (when enabled) at localhost:6600; no password
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
      makeWrapper ${mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${mopidyPackages.python.sitePackages}
    '';
  };
in
{
  sane.programs.mopidy = {
    package = mopidyWithExtensions (with pkgs; [
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
    persist.plaintext = [
      ".local/share/mopidy/local"  # thumbs, library db
    ];
    persist.private = [
      ".local/share/mopidy/http"  # cookie
    ];
    secrets.".config/mopidy/mopidy.conf" = ../../../secrets/common/mopidy.conf.bin;
    # other folders:
    # - .cache/mopidy
    # - .config/mopidy
  };
  # services.mopidy = lib.mkIf config.sane.programs.mopidy.enabled {
  #   enable = true;
  #   extensionPackages = with pkgs; [
  #     mopidy-iris  # web client: <https://github.com/jaedb/Iris>
  #     mopidy-jellyfin
  #     mopidy-local
  #     mopidy-mpd
  #     mopidy-mpris
  #     mopidy-spotify
  #     # TODO: mopidy-podcast, mopidy-youtube

  #     # alternate web clients:
  #     # mopidy-moped: <https://github.com/martijnboland/moped>
  #     # mopidy-muse: <https://github.com/cristianpb/muse>
  #   ];

  #   # config docs: <https://docs.mopidy.com/en/latest/config/>
  #   # to query config:
  #   # - `systemctl cat mopidy`
  #   # - copy the Exec line, then run it as daemon user with `config` arg, e.g.
  #   # - `sudo -u mopidy /nix/store/975g6qzz72ajsj7qcmq8123jbr0iq7fg-mopidy-with-extensions-3.4.1/bin/mopidy --config /nix/store/678mid699jcz4y56avyg4nsmjy0zmp7v-mopidy.conf config`
  #   configuration = ''
  #     [file]
  #     media_dirs =
  #       /home/colin/Music

  #     [iris]
  #     country = US
  #     locale = en_US
  #   '';
  #   # TODO:
  #   # set spotify.username, spotify.password, jellyfin....
  #   # but these are secret so can't go in the above configuration line
  #   # there is a configurationFiles option, though.
  # };
}
