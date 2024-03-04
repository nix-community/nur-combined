{ lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
}:

buildDotnetModule rec {
  pname = "thor";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Samsung-Loki";
    repo = "Thor";
    rev = version;
    hash = "sha256-tYzPpgbM9rCDdLW0ERZWmmxzMYpe1BNyFwmpaLQXRGQ=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;
  nugetDeps = ./nugetDeps.nix;
  projectFile = "TheAirBlow.Thor.Shell/TheAirBlow.Thor.Shell.csproj";

  postFixup = ''
    mv $out/bin/TheAirBlow.Thor.Shell $out/bin/thor
  '';

  meta = {
    homepage = "https://github.com/Samsung-Loki/Thor";
    description = "An alternative to Heimdall";
    license = lib.licenses.mpl20;
  };
}
