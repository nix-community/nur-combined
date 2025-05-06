{
  buildDotnetModule,
  lib,
  fetchFromGitHub,
  dotnet-sdk_6,
  dotnet-aspnetcore_6,
  callPackage,
  nodejs,
}: let
  dotnet = {
    sdk = dotnet-sdk_6;
    runtime = dotnet-aspnetcore_6;
  };

  version = "2.1.7-unstable-2025-02-21";
  src = fetchFromGitHub {
    owner = "thomst08";
    repo = "requestrr";
    rev = "6d9cf1e6071519ee0bfc4bbacb18393b3a919ef2";
    hash = "sha256-lUn+NFqFCF+244F/mvLK8tobFUzCy94NksuL1M9qQeE=";
  };

  webapp = callPackage ./webapp {inherit src;};
in
  buildDotnetModule {
    pname = "requestrr";

    inherit version src;

    projectFile = ["Requestrr.WebApi/Requestrr.WebApi.csproj"];
    nugetDeps = ./deps.json;

    dotnet-sdk = dotnet.sdk;
    dotnet-runtime = dotnet.runtime;

    nativeBuildInputs = [nodejs];

    postPatch = ''
      # Disable npm installs — we already have the dependencies
      substituteInPlace Requestrr.WebApi/Requestrr.WebApi.csproj \
      	--replace-fail "npm install" ":"
    '';

    preInstall = ''
      cp -r ${webapp}/lib/node_modules/requestrr/node_modules Requestrr.WebApi/ClientApp/node_modules
      chmod +w Requestrr.WebApi/ClientApp/node_modules
    '';

    executables = ["Requestrr.WebApi"];

    meta = {
      description = "Chatbot used to simplify using services like Sonarr/Radarr/Lidarr/Ombi/Overseerr via the use of chat";
      homepage = "https://github.com/thmost08/requestrr";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [TheColorman];
      platforms =
        lib.lists.intersectLists dotnet.runtime.meta.platforms
        nodejs.meta.platforms;
      mainProgram = "Requestrr.WebApi";
    };
    preferLocalBuild = true;
  }
