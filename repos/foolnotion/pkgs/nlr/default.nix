{ lib, fetchurl, buildDotnetModule, dotnetCorePackages, alglib, fetchFromGitHub }:

buildDotnetModule rec {
  pname = "nlr";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "HEAL.NonlinearRegression";
    rev = "c75cf04b4c2686fab09a445eb503b74336ba6b28";
    sha256 = "sha256-N6EhtxPY+oIy0sUbR3CZotShTKmgWjgMcSxPcJ7Bm0s=";

  };
  projectFile = "./HEAL.NonlinearRegression.sln";

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  nugetDeps = ./deps.nix;

  postFixup = ''
    # create a more convenient alias
    ln -sf $out/bin/HEAL.NonlinearRegression.Console $out/bin/nlr
    '';

  meta = with lib; {
    homepage = "https://github.com/heal-research/HEAL.NonlinearRegression";
    description = "C# implementation of nonlinear least squares fitting including calculation of t-profiles and pairwise profile plots";
    license = licenses.gpl3;
  };
}
