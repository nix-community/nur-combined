{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
}:

buildDotnetModule (finalAttrs: {
  pname = "cpp2il";
  version = "2022.1.0-pre-release.21-unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "SamboyCoding";
    repo = "Cpp2IL";
    rev = "b5ad444b82267cb1e4b88b8b373c008105bdea52";
    hash = "sha256-wWTl7X0eJgR84Tu5joUVeKsKuOfoV3sQsaO6Npt96wA=";
  };

  dotnet-sdk =
    with dotnetCorePackages;
    sdk_10_0
    // {
      inherit
        (combinePackages [
          sdk_9_0
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };

  projectFile = "Cpp2IL/Cpp2IL.csproj";
  nugetDeps = ./deps.json;

  dotnetInstallFlags = [ "--framework=net10.0" ];
  executables = [ "Cpp2IL" ];

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/SamboyCoding/Cpp2IL";
    description = "Work-in-progress tool to reverse unity's IL2CPP toolchain";
    mainProgram = "Cpp2IL";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
