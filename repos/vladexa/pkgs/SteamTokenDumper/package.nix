{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "SteamTokenDumper";
  version = "2025.04.28";

  src = fetchFromGitHub {
    owner = "SteamDatabase";
    repo = "SteamTokenDumper";
    rev = finalAttrs.version;
    hash = "sha256-8kLOozF60f6tg+a5VlmWYlWN4Nfh+pyx4m4Gxo5h4QQ=";
  };

  projectFile = "SteamTokenDumper.csproj";

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta = {
    description = "🔢 Submit users' PICS access tokens to SteamDB";
    homepage = "https://github.com/SteamDatabase/SteamTokenDumper";
    license = lib.licenses.mit;
    mainProgram = "SteamTokenDumper";
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
  };
})
