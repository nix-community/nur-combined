{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
}:

buildDotnetModule rec {
  pname = "wheelwizard";
  version = "2.4.11";

  src = fetchFromGitHub {
    owner = "TeamWheelWizard";
    repo = "WheelWizard";
    tag = "v${version}";
    hash = "sha256-8Dex2PDgwnxKguf0jtC1T0+jm7bA7jDfvspwkiqJgUg=";
  };

  projectFile = "WheelWizard/WheelWizard.csproj";
  nugetDeps = ./deps.json;

  meta = with lib; {
    description = "Retro Rewind Launcher";
    homepage = "https://github.com/TeamWheelWizard/WheelWizard";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "WheelWizard";
  };
}
