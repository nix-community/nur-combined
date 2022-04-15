{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, libGL
, freetype
, libdrm
, fontconfig
}:

stdenv.mkDerivation rec {
  pname = "activitywatch-bin";
  version = "0.11.0";

  src = fetchzip {
    url =
      "https://github.com/ActivityWatch/activitywatch/releases/download/v${version}/activitywatch-v${version}-linux-x86_64.zip";
    sha256 = "sha256-CYLhSxlKMHuIEMmqtN8o/lhwTfcR+DInFxVjZOJ1fHc=";
  };

  nativeBuildInputs = [ autoPatchelfHook libGL freetype libdrm fontconfig ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/
    ln -s $out/aw-qt $out/bin/aw-qt
    ln -s $out/aw-server/aw-server $out/bin/aw-server
    ln -s $out/aw-watcher-afk/aw-watcher-afk $out/bin/aw-watcher-afk
    ln -s $out/aw-watcher-window/aw-watcher-window $out/bin/aw-watcher-window
  '';

  meta = with lib; {
    homepage = "https://github.com/ActivityWatch/activitywatch";
    description =
      "The best free and open-source automated time tracker. Cross-platform, extensible, privacy-focused.";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };
}
