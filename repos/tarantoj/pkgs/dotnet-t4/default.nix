{
  lib,
  pkgs,
  buildDotnetModule,
  emptyDirectory,
  stdenv,
  mkNugetDeps,
}: let
  nugetName = "dotnet-t4";
  version = "2.3.1";
  nugetSha256 = "sha256-5Dyl15aP96k6fIRQq7v7U8AkC8IDf2QNpcKi7VBiSMQ=";
  pname = "t4";
in
  buildDotnetModule {
    inherit nugetName version nugetSha256 pname;

    src = emptyDirectory;

    executables = "t4";

    dotnet-runtime = pkgs.dotnet-sdk;

    nugetDeps = mkNugetDeps {
      name = pname;
      nugetDeps = {fetchNuGet}: [
        (fetchNuGet {
          pname = nugetName;
          inherit version;
          sha256 = nugetSha256;
        })
      ];
    };

    projectFile = "";

    useDotnetFromEnv = true;

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      dotnet tool install --tool-path $out/lib/${pname} ${nugetName} ${
        if stdenv.isAarch64
        then "--arch arm64"
        else ""
      }

      # remove files that contain nix store paths to temp nuget sources we made
      find $out -name 'project.assets.json' -delete
      find $out -name '.nupkg.metadata' -delete

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/mono/t4/blob/main/dotnet-t4/readme.md";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "t4";
      broken = true;
    };
  }
