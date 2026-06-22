{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  nuget-global-tool-update-script,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "7.2.0";

  nugetHash = "sha256-0oTDQG49P6UMNCl3a/AbH/tBXbOtW6fSOFt6ww/vk6o=";

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
