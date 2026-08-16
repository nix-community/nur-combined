{
  fetchFromGitHub,
  buildDotnetModule,
  stdenv,
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

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mkdir -p mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp $src/Flatpak/io.github.TeamWheelWizard.WheelWizard.desktop \
      $src/Flatpak/io.github.TeamWheelWizard.WheelWizard-url-handler.desktop \
      $out/share/applications
    cp $src/Flatpak/io.github.TeamWheelWizard.WheelWizard.png \
      $out/share/icons/hicolor/256x256/apps
  '';

  meta = with lib; {
    description = "Retro Rewind Launcher";
    homepage = "https://github.com/TeamWheelWizard/WheelWizard";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "WheelWizard";
  };
}
