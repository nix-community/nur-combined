{ audioQuality, drl-unwrapped, drl-common, fetchzip, lib }: let
    pname = "drl-${audioQuality}-audio";
    inherit (drl-unwrapped) version;
    tag = builtins.replaceStrings ["."] ["_"] version;
    shortVersion = lib.concatStrings (builtins.filter (x: builtins.match "[0-9]+" x != null) (builtins.splitVersion version));
    passthru = { inherit audioQuality; };
    fetchtgz = fetchzip.override { withUnzip = false; };
in if audioQuality == "hq" then fetchtgz {
    inherit pname version passthru;
    url = "https://github.com/chaosforgeorg/doomrl/releases/download/${tag}/drl-linux-${shortVersion}.tar.gz";
    postFetch = ''
        shopt -s extglob
        rm -r "$out"/!(mp3|wavhq)
        shopt -u extglob
    '';
    hash = "sha256-j1YzEAW40w+yBRT3MJz5IGe3gNvd4ede32SVhNAGjUc=";
    meta = drl-common.meta // {
        description = "${drl-common.meta.description} (high-quality audio files)";
    };
} else fetchtgz {
    inherit pname version passthru;
    url = "https://github.com/chaosforgeorg/doomrl/releases/download/${tag}/drl-linux-${shortVersion}-lq.tar.gz";
    postFetch = ''
        shopt -s extglob
        rm -r "$out"/!(music|wav)
        shopt -u extglob
    '';
    hash = "sha256-GyOklqXecE6jhN2dZ6XIliLAZQob7gPgnkW484MQeiw=";
    meta = drl-common.meta // {
        description = "${drl-common.meta.description} (low-quality audio files)";
    };
}
