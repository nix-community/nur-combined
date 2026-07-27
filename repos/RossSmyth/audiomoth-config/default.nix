{
  lib,
  fetchurl,
  appimageTools,
}:
lib.fix (
  finalAttrs:
  appimageTools.wrapType2 {
    pname = "audiomoth-config";
    version = "1.13.0";

    src = fetchurl {
      url = "https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/download/${finalAttrs.version}/AudioMothConfigurationAppSetup${finalAttrs.version}.AppImage";
      hash = "sha256-7aNRH22V4Ism2GEWgpxu2uOsFHziy12MqnuYHnyyGHo=";
    };

    # Seperate this as much as possible as it is super outdated
    unshareUser = true;
    unshareNet = true;
    privateTmp = true;
    unsharePid = true;
    unshareIpc = true;
    unshareUts = true;
    unshareCgroup = true;

    meta.mainProgram = "audiomoth-config";
  }
)
