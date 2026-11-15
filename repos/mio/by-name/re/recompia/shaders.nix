{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchzip,
  src,
  version,
}:
buildDotnetModule {
  pname = "recompia-shaders";
  inherit src version;
  projectFile = "tools/shaders/harness/SpirvHarness.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  nugetDeps = ./nuget-deps.json;
  executables = [ "spirv_harness" ];
  postPatch = ''
    mkdir -p refs
    ln -s ${
      fetchzip {
        url = "https://git.ryujinx.app/projects/Ryubing/archive/a82350bb774f70fcbd41c9987bf67a3775409963.tar.gz";
        hash = "sha256-PrfT+5BKYIe4+3xRkQtIBloF4r20jXdepBJlyNqJS9I=";
      }
    } refs/ryubing
    bash tools/shaders/scripts/setup_ryujinx.sh
    chmod -R u+w tools/shaders/third_party
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/spirv_harness --help
    runHook postInstallCheck
  '';
}
