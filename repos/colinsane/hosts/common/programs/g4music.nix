# N.B.: requires first-run setup on moby:
# - UI will render transparent
# - click the hamburger (top-right: immediately left from close button)
#   > Preferences
#     > Background-blur mode: change from "Always" to "Never"
#
# the background blur is probably some dconf setting somewhere.
{ ... }:
{
  sane.programs.g4music = {
    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # mpris
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
    ];

    sandbox.mesaCacheDir = ".cache/com.github.neithern.g4music/mesa";
    persist.byStore.plaintext = [
      # index?
      ".cache/com.github.neithern.g4music"
    ];
  };
}
