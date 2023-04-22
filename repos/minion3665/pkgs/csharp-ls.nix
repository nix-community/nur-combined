{ lib
, fetchFromGitHub
, buildDotnetPackage
, pkg-config
, dotnet-sdk
, dotnetPackages
, msbuild
,
}:
let
  rev = "4fdada72e9a08a810da8e332258ae0dcc7e89cc7";
in
buildDotnetPackage rec {
  pname = "csharp-ls";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "razzmatazz";
    repo = "csharp-language-server";
    inherit rev;
    sha256 = "sha256-+fc1mlNG9rxqQXaQXsGY228hz7zu2zaj3NlfDlNdn8U=";
  };
  projectFile = "src/csharp-language-server.sln";
  buildInputs = [
    msbuild
    dotnet-sdk
    dotnetPackages.NUnit
    dotnetPackages.NUnitRunners
  ];
  nativeBuildInputs = [
    pkg-config
  ];
  nugetDeps = ./csharp-ls/deps.nix;
  buildPhase = ''
    runHook preBuild

    msbuild ${projectFile} /p:Configuration=Release
    runHook postBuild
  '';
  meta = with lib; {
    homepage = "https://github.com/razzmatazz/csharp-language-server";
    description = "A csharp language server";
    license = licenses.mit;
    maintainer = [ maintainers.minion3665 ];
  };
}
