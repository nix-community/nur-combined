{
  buildDotnetModule,
  dotnetCorePackages,
  emgucv,
  fetchFromGitHub,
  lib,
}:
buildDotnetModule rec {
  pname = "UVtools";
  version = "5.2.1";
  src = fetchFromGitHub {
    owner = "sn4k3";
    repo = "UVtools";
    rev = "v${version}";
    hash = "sha256-59cW3aR7UuYKACd0WIubxBqQQIFQiX4eNR3cPIg3vVk=";
  };

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  runtimeDeps = [
    emgucv
  ];

  # available projects:
  # - UVtools.Installer/UVtools.Installer.wixproj  (needs WixToolset, not in nixpkgs)
  # - UVtools.Core/UVtools.Core.csproj
  # - UVtools.UI/UVtools.UI.csproj
  # - Scripts/UVtools.ScriptSample/UVtools.ScriptSample.csproj
  # - UVtools.AvaloniaControls/UVtools.AvaloniaControls.csproj
  # - UVtools.Cmd/UVtools.Cmd.csproj
  # TODO: install the UI, and maybe AvaloniaControls too
  projectFile = "UVtools.Cmd/UVtools.Cmd.csproj";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "MSLA/DLP, file analysis, calibration, repair, conversion and manipulation";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
