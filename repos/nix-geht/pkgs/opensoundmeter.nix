{
  stdenv,
  lib,
  pkgs,
  qmake,
  qtbase,
  qtquickcontrols2,
  qtgraphicaleffects,
  wrapQtAppsHook,
  alsaSupport ? stdenv.isLinux,
  alsa-lib ? null,
}:
# TODO: Verify on Darwin. Probably needs work as it installs an App.
stdenv.mkDerivation rec {
  pname = "opensoundmeter";
  version = "1.3";

  src = pkgs.fetchFromGitHub {
    owner = "psmokotnin";
    repo = "osm";
    rev = "v${version}";
    hash = "sha256-nRibcEtG6UUTgn7PhSg4IyahMYi5aSPvaEOrAdx6u3o=";
  };

  nativeBuildInputs = [qmake wrapQtAppsHook];
  buildInputs =
    [qtbase qtquickcontrols2 qtgraphicaleffects]
    ++ lib.optionals alsaSupport [alsa-lib];

  postPatch = ''
    # We don't need the app image stuff.
    sed -i '/linuxdeployosm/d' OpenSoundMeter.pro

    # We want our prefix to be used.
    sed -i "s%target.path = .*$%target.path = $out/bin%" OpenSoundMeter.pro

    # Patch the version.
    sed -i "s/APP_GIT_VERSION = .*/APP_GIT_VERSION = v${version}/" OpenSoundMeter.pro
  '';

  meta = with lib; {
    homepage = "https://opensoundmeter.com/";
    description = "Sound measurement application for tuning audio systems in real-time";
    license = with licenses; [gpl3];
    maintainers = with maintainers; [vifino];
    platforms = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-linux"
    ];
  };
}
