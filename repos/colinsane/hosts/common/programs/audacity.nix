{ pkgs, ... }:
{
  sane.programs.audacity = {
    package = pkgs.audacity.override {
      # wxGTK32 uses webkitgtk-4.0.
      # audacity doesn't actually need webkit though, so diable to reduce closure
      wxGTK32 = pkgs.wxGTK32.override {
        withWebKit = false;
      };
    };

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
