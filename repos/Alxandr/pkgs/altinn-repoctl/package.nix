{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "altinn-repoctl";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Altinn";
    repo = "altinn-authorization-utils";
    tag = "tool/RepoCtl-v${finalAttrs.version}";
    hash = "sha256-U0l80o76b7kJwZT8gf/mIL7JVma6qg1cw+yxg2JBSHY=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.sdk_10_0;

  useDotnetFromEnv = true;

  makeWrapperArgs = [
    "--set"
    "DOTNET_ROOT"
    "${dotnetCorePackages.runtime_10_0}/share/dotnet"
  ];

  projectFile = [
    "src/tools/Altinn.Authorization.RepoCtl/src/RepoCtl.Cli/Altinn.Authorization.RepoCtl.Cli.csproj"
  ];
  testProjectFile = [
    "src/tools/Altinn.Authorization.RepoCtl/test/RepoCtl.Cli.Tests/Altinn.Authorization.RepoCtl.Tests.csproj"
  ];
  nugetDeps = ./deps.json;
  dotnetFlags = [
    "-p:TargetFramework=net10.0"
  ];

  MINVERVERSIONOVERRIDE = finalAttrs.version;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ ];
    };
  };

  meta = {
    description = "A dotnet tool for managing Altinn repositories";
    homepage = "https://github.com/Altinn/altinn-authorization-utils";
    license = lib.licenses.mit;
    mainProgram = "repoctl";
  };
})
