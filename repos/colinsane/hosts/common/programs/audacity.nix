{ pkgs, ... }:
{
  sane.programs.audacity = {
    packageUnwrapped = pkgs.audacity.override {
      # wxGTK32 uses webkitgtk-4.0.
      # audacity doesn't actually need webkit though, so diable to reduce closure
      wxGTK32 = pkgs.wxGTK32.override {
        withWebKit = false;
      };
    };

    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = true;
    sandbox.extraHomePaths = [
      # support media imports via file->open dir to some common media directories
      "tmp"
      "Music"
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
    # audacity needs the entire config dir mounted if running in a sandbox
    fs.".config/audacity".dir = {};
  };
}
