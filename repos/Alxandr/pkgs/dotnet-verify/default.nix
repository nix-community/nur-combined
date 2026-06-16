{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "dotnet-verify";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "VerifyTests";
    repo = "Verify.Terminal";
    tag = "${finalAttrs.version}";
    hash = "sha256-64rW1diVGJDALraCoeNN0q11A4UcSPUvPJbalp88ciA=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  projectFile = [ "src/Verify.Terminal/Verify.Terminal.csproj" ];
  testProjectFile = [ "src/Verify.Terminal.Tests/Verify.Terminal.Tests.csproj" ];
  nugetDeps = ./deps.json;
  dotnetInstallFlags = [
    "-f"
    "net10.0"
  ];

  postFixup = ''
    mv "$out/bin/Verify.Terminal" "$out/bin/dotnet-verify"
  '';

  MINVERVERSIONOVERRIDE = finalAttrs.version;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ ];
    };
  };

  meta = {
    description = "A dotnet tool for managing Verify snapshots";
    homepage = "https://github.com/VerifyTests/Verify.Terminal";
    license = lib.licenses.mit;
    mainProgram = "dotnet-verify";
  };
})
