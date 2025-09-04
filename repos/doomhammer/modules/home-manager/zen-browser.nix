{ inputs, ... }:
let
  modulePath = [
    "my"
    "programs"
    "zen-browser"
  ];
  mkFirefoxModule = import "${inputs.home-manager}/modules/programs/firefox/mkFirefoxModule.nix";
in
{
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "Zen";
      wrappedPackageName = "zen";
      unwrappedPackageName = "zen-unwrapped";
      visible = true;

      platforms.linux = {
        configPath = ".zen";
      };
      platforms.darwin = {
        configPath = "Library/Application Support/Zen";
      };
    })
  ];
}
