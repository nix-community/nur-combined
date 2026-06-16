{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "NugetMcpServer";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "DimonSmart";
    repo = "NugetMcpServer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1PU+EiE1c94zp5Kp8ehX7RTtJTAajQl9m6pv+BaA0Tg=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  projectFile = [ "NugetMcpServer/NugetMcpServer.csproj" ];
  testProjectFile = [ "NugetMcpServer.Tests/NugetMcpServer.Tests.csproj" ];
  nugetDeps = ./deps.json;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "MCP server for finding and inspecting NuGet packages";
    homepage = "https://github.com/DimonSmart/NugetMcpServer";
    license = lib.licenses.unlicense;
    mainProgram = "NugetMcpServer";
  };
})
