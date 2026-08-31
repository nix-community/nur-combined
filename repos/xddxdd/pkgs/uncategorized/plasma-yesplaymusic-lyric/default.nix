{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-yesplaymusic-lyric";
  version = "0.2.3-unstable-2025-01-07";
  src = fetchFromGitHub {
    owner = "zsiothsu";
    repo = "org.kde.plasma.yesplaymusic-lyrics";
    rev = "8f4bc05980195fef4b66474dccbfaa87912e3097";
    hash = "sha256-5sb4RxF9tDK5Ha51W6vhC3V0hN/ANbKYY40iyzTJ0W0=";
  };
  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.yesplaymusic-lyrics
    cp -r * $out/share/plasma/plasmoids/org.kde.plasma.yesplaymusic-lyrics
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics";
    tagPrefix = "v";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Display YesPlayMusic lyrics on the plasma panel | 在KDE plasma面板中显示YesPlayMusic的歌词";
    homepage = "https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics";
    license = lib.licenses.mit;
  };
})
