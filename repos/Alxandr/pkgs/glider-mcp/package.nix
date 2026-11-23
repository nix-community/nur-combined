{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  nuget-global-tool-update-script,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "17.0.1";

  nugetHash = "sha256-Qeqb0MVVpQCRxALZKbtW1kUwsFWfxV6S7sipgmIhzr4=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  passthru = {
    updateScript = nuget-global-tool-update-script { };
  };

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}
