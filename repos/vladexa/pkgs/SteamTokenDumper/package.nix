{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "SteamTokenDumper";
  version = "2026.08.20";

  src = fetchFromGitHub {
    owner = "SteamDatabase";
    repo = "SteamTokenDumper";
    rev = finalAttrs.version;
    hash = "sha256-dpdH05kYjz3FFVfPWDuzox3kfnv69qFfHYjSb2Bywkk=";
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
