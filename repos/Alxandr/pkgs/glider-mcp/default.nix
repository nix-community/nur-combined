{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  nuget-global-tool-update-script,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "9.1.0";

  nugetHash = "sha256-Y74HAMuskHEivCwp92vlrK3xWzFUHIzwkYm+QyY+jkM=";

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
