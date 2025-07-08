{
  fetchFromGitHub,
  lib,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "minecraft-console-client";
  version = "20250522-285";

  src = fetchFromGitHub {
    owner = "milutinke";
    repo = "Minecraft-Console-Client";
    rev = "304c8f04f2f9ef16dfb752f86e75712f5b8a2616";
    fetchSubmodules = true;
    hash = "sha256-8D0SVI70PAEyY1QM20yLj+bMDsbUGJ+6rma8MPaisf0=";
  };

  projectFile = "MinecraftClient/MinecraftClient.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnetFlags = [ "-p:RuntimeFrameworkVersion=${dotnet-runtime.version}" ];

  meta = {
    mainProgram = "MinecraftClient";
    description = "Lightweight console for Minecraft chat and automated scripts";
    homepage = "https://github.com/milutinke/Minecraft-Console-Client";
    license = lib.licenses.cddl;
  };
}

