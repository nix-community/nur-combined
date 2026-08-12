{
  stdenvNoCC,
  parabolic,
  fetchurl,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "parabolic";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Graphical frontend for yt-dlp to download video and audio";
      longDescription = ''
        Parabolic is a user-friendly adwaita application for `yt-dlp`
        that supports many features including but not limited to:

        - Downloading and converting videos and audio using ffmpeg.
        - Supporting multiple codecs.
        - Offering YouTube sponsorblock support.
        - Running multiple downloads at a time.
        - Downloading metadata and video subtitles.
        - Allowing the use of `aria2` for parallel downloads.
        - Offering a graphical keyring to manage account credentials.
      '';
      homepage = "https://github.com/NickvisionApps/Parabolic";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Plus;
    };
  })
else parabolic
