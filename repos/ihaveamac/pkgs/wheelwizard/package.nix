{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  stdenv,
  lib,
}:

buildDotnetModule rec {
  pname = "wheelwizard";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "TeamWheelWizard";
    repo = "WheelWizard";
    tag = "v${version}";
    hash = "sha256-r8H2UCsasYTZ4sChzHbgFDKmccQEnYkA8WfR+UmLzrM=";
  };

  projectFile = "WheelWizard/WheelWizard.csproj";
  nugetDeps = ./deps.json;

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

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
