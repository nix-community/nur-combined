{
  buildDotnetModule,
  dotnetCorePackages,
  emgucv,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {
  pname = "UVtools";
  version = "6.0.3";
  src = fetchFromGitHub {
    owner = "sn4k3";
    repo = "UVtools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XAi0CnBsSZPmlQCLciAPue3G8JN8WYd8BkBo44Xan94=";
  };

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MSLA/DLP, file analysis, calibration, repair, conversion and manipulation";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "UVtoolsCmd";
  };
})
