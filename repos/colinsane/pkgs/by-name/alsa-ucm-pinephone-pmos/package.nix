# see: https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/main/device-pine64-pinephone/
# - APKBUILD and ucm/ files
{
  alsa-ucm-conf,
  lib,
  fetchFromGitLab,
  preferEarpiece ? false,
}:
let
  pmaports = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "006256a0d001bf131963b69b24ae538e0bff4998";
    hash = "sha256-AL3wxDN4V9K7eindEkDGNlBLV4vVMf9b7ny0BQwvbek=";
  };
  pmosAdditions = "${pmaports}/device/main/device-pine64-pinephone/ucm";
in alsa-ucm-conf.overrideAttrs (upstream: {
  pname = upstream.pname + "-pmos-2024-05-26";
  postInstall = (upstream.postInstall or "") + ''
    install -Dm644 -t $out/share/alsa/ucm2/PinePhone \
      ${pmosAdditions}/HiFi.conf \
      ${pmosAdditions}/PinePhone.conf \
      ${pmosAdditions}/VoiceCall.conf
    mkdir -p $out/share/alsa/ucm2/conf.d/simple-card
    ln -sf $out/share/alsa/ucm2/PinePhone/PinePhone.conf \
      $out/share/alsa/ucm2/conf.d/simple-card/PinePhone.conf
  '' + lib.optionalString preferEarpiece ''
    # decrease the priority of the internal speaker so that sounds are routed
    # to the earpiece by default.
    # this is just personal preference.
    substituteInPlace $out/share/alsa/ucm2/PinePhone/{HiFi.conf,VoiceCall.conf} \
      --replace-fail 'PlaybackPriority 300' 'PlaybackPriority 100'
  '';
})
