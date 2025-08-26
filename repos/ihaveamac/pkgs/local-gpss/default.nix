{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "local-gpss";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "FlagBrew";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kMTJoPcVQEQxoB0HpiIVGheLweFQLVyjwH9yYie2gUc=";
  };

  projectFile = "local-gpss.csproj";
  nugetDeps = ./deps.json;

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  # remove unneeded binary (why did it put a shared library here?)
  postFixup = ''
    rm $out/bin/libe_sqlite3${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  meta = with lib; {
    description = "A C# API server that can be used to locally host GPSS";
    homepage = "https://github.com/FlagBrew/local-gpss";
    platforms = platforms.all;
    mainProgram = "local-gpss";
  };
}
