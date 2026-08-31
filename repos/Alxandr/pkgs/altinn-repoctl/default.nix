{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "altinn-repoctl";
  version = "v1.1.0";

  src = fetchFromGitHub {
    owner = "Altinn";
    repo = "altinn-authorization-utils";
    tag = "tool/RepoCtl-${finalAttrs.version}";
    hash = "sha256-nxYjXB+bbmAdpdYws1DTshhzihQB0IlLRB70bgByOrw=";
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
    "src/tools/Altinn.Authorization.RepoCtl/src/RepoCtl/Altinn.Authorization.RepoCtl.csproj"
  ];
  testProjectFile = [
    "src/tools/Altinn.Authorization.RepoCtl/test/RepoCtl.Tests/Altinn.Authorization.RepoCtl.Tests.csproj"
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
    description = "A dotnet tool for managing Verify snapshots";
    homepage = "https://github.com/Altinn/altinn-authorization-utils";
    license = lib.licenses.mit;
    mainProgram = "repoctl";
  };
})
