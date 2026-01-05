{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "SteamTokenDumper";
  version = "2025.12.17";

  src = fetchFromGitHub {
    owner = "SteamDatabase";
    repo = "SteamTokenDumper";
    rev = finalAttrs.version;
    hash = "sha256-LKUrATMbmJYwukJYO4Y1DkD2gPj06B8R7pLRiy+4Gr8=";
  };

  projectFile = "SteamTokenDumper.csproj";

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

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
