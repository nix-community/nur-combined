{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  git,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "utmt-cli";
  version = "0.9.2.0";

  src = fetchFromGitHub {
    owner = "UnderminersTeam";
    repo = "UndertaleModTool";
    tag = finalAttrs.version;
    hash = "sha256-I1UxVJ3AKRDPmYs0MoYXGukcj7krycVKb4jEZ4Y0pjI=";
    fetchSubmodules = true;
  };

  projectFile = "UndertaleModCli/UndertaleModCli.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  packNupkg = true;
  selfContainedBuild = true;
  executables = [
    "UndertaleModCli"
  ];

  nativeBuildInputs = [
    git
  ];

  postFixup = ''
    ln -s $out/bin/UndertaleModCli $out/bin/utmt
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The most complete tool for modding, decompiling and unpacking Undertale (and other GameMaker games!)";
    homepage = "https://github.com/UnderminersTeam/UndertaleModTool";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ claymorwan ];
    mainProgram = "utmt";
  };
})
