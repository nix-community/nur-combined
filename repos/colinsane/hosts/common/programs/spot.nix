{ ... }:
{
  sane.programs.spot = {
    buildCost = 1;

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # mpris
    sandbox.whitelistWayland = true;

    secrets.".cache/spot/librespot/credentials/credentials.json" = ../../../secrets/common/spot_credentials.json.bin;
    persist.byStore.plaintext = [
      ".cache/spot/img"  # album art
      ".cache/spot/librespot/audio"  # audio/track cache
      ".cache/spot/net"  # album metadata
    ];
  };
}
