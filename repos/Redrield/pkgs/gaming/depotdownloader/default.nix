{ buildDotnetModule, lib, fetchFromGitHub, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "depotdownloader";
  version = "2.6.0";

  src = fetchFromGitHub {
    repo = "DepotDownloader";
    owner = "SteamRE";
    rev = "master";
    sha256 = "0dqdmlkn5fx5dprg314q0xlpif5gwfmnmi58yg98jmgf6qkanz22";
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
