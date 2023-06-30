{ lib, fetchurl, buildDotnetModule, dotnetCorePackages, alglib, fetchFromGitHub }:

buildDotnetModule rec {
  pname = "nlr";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "HEAL.NonlinearRegression";
    rev = "037863b51f9f4190fbb9274dfc7fb3d90240b181";
    sha256 = "sha256-XqTAIjJnljgI5h6ikojOkJYbmPqABetj7aGu2A0D/3E=";

  };
  projectFile = "./HEAL.NonlinearRegression.sln";

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
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
