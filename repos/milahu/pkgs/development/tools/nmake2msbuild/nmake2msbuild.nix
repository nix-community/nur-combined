{ lib
, buildDotnetModule
, fetchFromGitHub
, dotnetCorePackages
}:

buildDotnetModule rec {
  pname = "nmake2msbuild";
  # error : 'unstable-2023-09-22' is not a valid version string.
  #version = "unstable-2023-09-22";
  # error : '2023,09.22' is not a valid version string.
  #version = "2023,09.22";
  # 4 = 4 commits
  version = "0.4";

  src = fetchFromGitHub {
    owner = "Footsiefat";
    repo = "NMake2MSBuild";
    rev = "6921d3bb548c369f79c6c735ecbe6e504efbc411";
    hash = "sha256-qJC1yBxQm39GkFLRMZ8EvVILBWhcroBYvjGu3impQCw=";
  };

  projectFile = "nmake2msbuild.csproj";

  nugetDeps = ./nuget-deps.nix;

  # fix: error NETSDK1045: The current .NET SDK does not support targeting .NET 7.0.
  # nmake2msbuild.csproj: <TargetFramework>net7</TargetFramework>
  dotnet-sdk = dotnetCorePackages.sdk_7_0;

  # fix: You must install or update .NET to run this application.
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  # fix: File "/nix/store/h0yjp2682840xfraprqllyy3m2b3awmr-nmake2msbuild-1.0/lib/nmake2msbuild/conversion/AutoConverted.vcxproj.template" not found
  postInstall = ''
    mkdir -p $out/lib/nmake2msbuild
    cp -r conversion $out/lib/nmake2msbuild
  '';

  meta = with lib; {
    description = "A universal source port of NMake2MSBuild including experimental Linux support";
    homepage = "https://github.com/Footsiefat/NMake2MSBuild";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
