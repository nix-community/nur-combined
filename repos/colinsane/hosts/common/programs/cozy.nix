{ pkgs, ... }:

{
  sane.programs.cozy = {
    packageUnwrapped = pkgs.cozy.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        # disable all reporting.
        # this can be done via the settings, but that's troublesome and easy to forget.
        # specifically, i don't want moby to be making these network requests several times per hour
        # while it might be roaming or trying to put the RF to sleep.
        substituteInPlace cozy/application_settings.py \
          --replace-fail 'self._settings.get_int("report-level")' '0'
      '';
    });

    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # mpris
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Books/Audiobooks"
      "Books/local"
      "Books/servo"
    ];

    # cozy uses a sqlite db for its config and exposes no CLI options other than --help and --debug
    persist.byStore.plaintext = [
      ".local/share/cozy"  # sqlite db (config & index?)
      ".cache/cozy"  # offline cache
    ];
  };
}
