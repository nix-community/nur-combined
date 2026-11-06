{
  qbittorrent-enhanced,
  lib,
  stdenv,
}:

qbittorrent-enhanced.overrideAttrs (
  old:
  lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Qt 6.10+ marks Q_OS_MAC as a deprecated macro, and qBittorrent 5.2.3
    # compiles with -Werror, which kills the darwin build. Q_OS_MACOS is the
    # non-deprecated spelling of the same check.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/gui/log/loglistview.cpp src/gui/optionsdialog.cpp \
        --replace-fail "#ifdef Q_OS_MAC" "#ifdef Q_OS_MACOS"
    '';
  }
)
