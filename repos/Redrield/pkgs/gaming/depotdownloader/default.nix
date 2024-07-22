{ buildDotnetModule, lib, fetchFromGitHub, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "depotdownloader";
  version = "2.6.0";

  src = fetchFromGitHub {
    repo = "DepotDownloader";
    owner = "SteamRE";
    rev = "DepotDownloader_${version}";
    hash = "sha256-QnyrJjbuVYnS86jEaqvjr7h4aQeYhPHybaW7YietDTc=";
  };

  projectFile = "DepotDownloader.sln";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.dotnet_8.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_8.runtime;

  runtimeDeps = [];

  meta = with lib; {
    license = licenses.gpl2Plus;
  };
}
