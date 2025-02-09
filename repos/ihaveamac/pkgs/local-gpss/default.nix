{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "local-gpss";
  version = "0-unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "FlagBrew";
    repo = pname;
    rev = "ca2422cb29b1e8d85a04768a470e96eff6b81344";
    hash = "sha256-Ym6mWJ7CCl1nOqwUiItIPjL/p5kjn3f7I1/CBdV09m8=";
  };

  projectFile = "local-gpss/local-gpss.csproj";
  nugetDeps = ./deps.json;

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  meta = with lib; {
    description = "A C# API server that can be used to locally host GPSS";
    homepage = "https://github.com/FlagBrew/local-gpss";
    platforms = platforms.all;
    mainProgram = "local-gpss";
  };
}
