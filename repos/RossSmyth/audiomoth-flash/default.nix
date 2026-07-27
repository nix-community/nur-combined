{
  lib,
  fetchurl,
  appimageTools,
}:
lib.fix (
  finalAttrs:
  appimageTools.wrapType2 {
    pname = "audiomoth-flash";
    version = "1.7.2";

    src = fetchurl {
      url = "https://github.com/OpenAcousticDevices/AudioMoth-Flash-App/releases/download/${finalAttrs.version}/AudioMothFlashAppSetup${finalAttrs.version}.AppImage";
      hash = "sha256-BAGsFBM1N2JV/EKex2sDnhwyH+HX+bGtH2H2Da80ElM=";
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
