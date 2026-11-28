{
  fetchFromGitHub,
  lib,
  callPackage,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule (
  finalAttrs:
  let
    frontend = callPackage ./frontend.nix {
      inherit (finalAttrs) src version;
      npmDepsHash = "sha256-dVIrK9dplcG+T49AwlShOHZePbNumDwM94MQ+QMTIK4=";
    };
  in
  {
    pname = "cleanuparr";
    version = "2.11.2";
    src = fetchFromGitHub {
      owner = "Cleanuparr";
      repo = "Cleanuparr";
      tag = "v${finalAttrs.version}";
      hash = "sha256-KMa8ePF682GnXRLuTL9SXYjLJDz14v5Geglk1vFL6vw=";
    };
    __structuredAttrs = true;
    strictDeps = true;

    sourceRoot = "source/code/backend";
    projectFile = "Cleanuparr.Api/Cleanuparr.Api.csproj";

    nugetDeps = ./nuget-deps.json;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.runtime_10_0;

    selfContainedBuild = true;
    dotnetFlags = [
      "-p:PublishSingleFile=true"
      "-p:DebugSymbols=false"
    ];

    executables = [ "Cleanuparr" ];

    postPatch = ''
      rm -rf Cleanuparr.Api/wwwroot
      cp -r ${frontend}/wwwroot Cleanuparr.Api/wwwroot
    '';

    postFixup = ''
      ln -s Cleanuparr $out/bin/cleanuparr
    '';

    # Write runtime config/logs outside the read-only store by default.
    makeWrapperArgs = [
      "--chdir"
      "${placeholder "out"}/lib/cleanuparr"
      "--run"
      ''export CLEANUPARR_CONFIG_PATH="''${CLEANUPARR_CONFIG_PATH:-''${XDG_CONFIG_HOME:-$HOME/.config}/cleanuparr}"''
    ];

    passthru = {
      inherit (frontend) npmDeps;
      updateScript = nix-update-script { };
    };
    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Advanced download manager for the Servarr ecosystem";
      homepage = "https://github.com/Cleanuparr/Cleanuparr";
      license = lib.licenses.gpl3Only;
      mainProgram = "cleanuparr";
      platforms = [ "x86_64-linux" ];
    };
  }
)
