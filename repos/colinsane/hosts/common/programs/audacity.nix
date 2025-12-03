# tips/tricks
# - audio recording
#   - default recording input will be silent, on lappy.
#   - Audio Setup -> Rescan Audio Devices ...
#   - Audio Setup -> Recording device -> sysdefault
{ lib, pkgs, ... }:
let
  # wxGTK32 uses webkitgtk-4.0.
  # audacity doesn't actually need webkit though, so diable to reduce closure
  wxGTK32 = pkgs.wxGTK32.override {
    withWebKit = false;
  };
  basePkg = pkgs.audacity.overrideAttrs (base: {
    # upstream audacity.desktop specifies GDK_BACKEND=x11, with which it doesn't actually launch :|
    postInstall = (base.postInstall or "") + ''
      substituteInPlace $out/share/applications/${appId}.desktop \
        --replace-fail 'GDK_BACKEND=x11 ' ""
    '';

    # XXX(2025-03-03): upstream nixpkgs incorrectly defaults `GDK_BACKEND=x11`,
    # even though audacity runs fine on wayland
    postFixup = lib.replaceStrings [ "--set-default GDK_BACKEND x11" ] [ "" ] base.postFixup;
  });
  # basePkg = pkgs.tenacity;  #< uncomment if the audacity build breaks
  appId = basePkg.pname;
in
{
  sane.programs.audacity = {
    packageUnwrapped = basePkg.override {
      inherit wxGTK32;
    };

    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";
    sandbox.extraHomePaths = [
      # support media imports via file->open dir to some common media directories
      "tmp"
      "Music"
      # audacity needs the entire config dir mounted if running in a sandbox
      ".config/${appId}"
    ];
    sandbox.extraPaths = [
      "/dev/snd"  # for recording audio inputs to work
    ];

    # disable first-run splash screen
    fs.".config/${appId}/${appId}.cfg".file.text = ''
      PrefsVersion=1.1.1r1
      [GUI]
      ShowSplashScreen=0
      [Version]
      Major=${lib.versions.major basePkg.version}
      Minor=${lib.versions.minor basePkg.version}
      Micro=${lib.versions.patch basePkg.version}
    '';
  };
}
