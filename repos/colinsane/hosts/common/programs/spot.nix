{ ... }:
{
  sane.programs.spot = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    secrets.".cache/spot/librespot/credentials/credentials.json" = ../../../secrets/common/spot_credentials.json.bin;
    persist.byStore.plaintext = [
      ".cache/spot/img"  # album art
      ".cache/spot/librespot/audio"  # audio/track cache
      ".cache/spot/net"  # album metadata
    ];
  };
}
