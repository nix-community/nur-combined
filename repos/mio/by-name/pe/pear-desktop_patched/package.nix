{
  pear-desktop,
  makeDesktopItem,
  stdenv,
  lib,
}:
if stdenv.isDarwin then
  pear-desktop # TODO: what bug is it?
else
  pear-desktop.overrideAttrs (
    old:
    {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/plugins/do-not-track/index.ts \
          --replace-fail "enabled: false," "enabled: true,"
        substituteInPlace src/plugins/sponsorblock/index.ts \
          --replace-fail "enabled: false," "enabled: true,"
      '';
    }
    // lib.optionalAttrs stdenv.isLinux {
      pname = "pear-desktop_patched";
      desktopItems = [
        (makeDesktopItem {
          name = "com.github.th-ch.youtube-music";
          exec = "pear-desktop %u";
          icon = "pear-desktop";
          desktopName = "YouTube Music";
          startupWMClass = "com.github.th-ch.youtube-music";
          categories = [ "AudioVideo" ];
        })
      ];
    }
  )
