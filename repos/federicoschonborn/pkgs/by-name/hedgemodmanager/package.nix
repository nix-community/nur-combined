{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  nix-update-script,
}:

let
  version = "8.0.0.1";

in

buildDotnetModule {
  pname = "hedgemodmanager";
  inherit version;

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "HedgeModManager";
    rev = version;
    hash = "sha256-Aj5hepS6mFcUVhGf9Prjfqd7o6U2lHzwXK33Y3qelgs=";
  };

  projectFile = "Source/HedgeModManager.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "HedgeModManager.UI";
    description = "Multiplatform rewrite of Hedge Mod Manager";
    homepage = "https://github.com/hedge-dev/HedgeModManager";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
