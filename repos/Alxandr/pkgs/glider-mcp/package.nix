{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  nuget-global-tool-update-script,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "12.0.2";

  nugetHash = "sha256-C8IR6HVEx/e9YjsNCsAnxv8HIb9Xw6yoHffVTRoSyjE=";

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
