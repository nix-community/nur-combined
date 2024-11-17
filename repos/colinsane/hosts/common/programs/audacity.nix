# tips/tricks
# - audio recording
#   - default recording input will be silent, on lappy.
#   - Audio Setup -> Rescan Audio Devices ...
#   - Audio Setup -> Recording device -> sysdefault
{ pkgs, ... }:
{
  sane.programs.audacity = {
    packageUnwrapped = (pkgs.audacity.override {
      # wxGTK32 uses webkitgtk-4.0.
      # audacity doesn't actually need webkit though, so diable to reduce closure
      wxGTK32 = pkgs.wxGTK32.override {
        withWebKit = false;
      };
    }).overrideAttrs (base: {
      # upstream audacity.desktop specifies GDK_BACKEND=x11, with which it doesn't actually launch :|
      postInstall = (base.postInstall or "") + ''
        substituteInPlace $out/share/applications/audacity.desktop \
          --replace-fail 'GDK_BACKEND=x11 ' ""
      '';
    });

    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";
    sandbox.extraHomePaths = [
      # support media imports via file->open dir to some common media directories
      "tmp"
      "Music"
      # audacity needs the entire config dir mounted if running in a sandbox
      ".config/audacity"
    ];
    sandbox.extraPaths = [
      "/dev/snd"  # for recording audio inputs to work
    ];

    # disable first-run splash screen
    fs.".config/audacity/audacity.cfg".file.text = ''
      PrefsVersion=1.1.1r1
      [GUI]
      ShowSplashScreen=0
      [Version]
      Major=3
      Minor=4
    '';
  };
}
