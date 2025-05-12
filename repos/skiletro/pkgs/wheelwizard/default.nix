{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  makeDesktopItem
}:
buildDotnetModule rec {
  pname = "wheelwizard";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "TeamWheelWizard";
    repo = "WheelWizard";
    rev = "${version}";
    sha256 = "sha256-Fw/Tj3HVZL1ttH/6eL8G9ZXs74hx+Ec1BOvT0FOicBU=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "Wheel Wizard";
      exec = "wheelwizard";
      icon = "wheelwizard";
      comment = "Mario Kart Wii Mod Manager";
      desktopName = "Wheel Wizard";
    })
  ];

  projectFile = "WheelWizard/WheelWizard.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  nugetDeps = ./deps.nix;

  meta.description = "WheelWizard, Retro Rewind Launcher";
}
