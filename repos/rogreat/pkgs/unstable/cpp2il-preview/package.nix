{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
}:

buildDotnetModule (finalAttrs: {
  pname = "cpp2il-preview";
  version = "2022.1.0-pre-release.21";

  src = fetchFromGitHub {
    owner = "SamboyCoding";
    repo = "Cpp2IL";
    tag = finalAttrs.version;
    hash = "sha256-1bO7MhKcsxLY7ReMlEdh5z8BkpGA89HykKybIPYmQuA=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  projectFile = "Cpp2IL/Cpp2IL.csproj";
  nugetDeps = ./deps.json;

  dotnetInstallFlags = [ "--framework=net9.0" ];
  executables = [ "Cpp2IL" ];

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/SamboyCoding/Cpp2IL";
    changelog = "https://github.com/SamboyCoding/Cpp2IL/releases/tag/${finalAttrs.src.tag}";
    description = "Work-in-progress tool to reverse unity's IL2CPP toolchain";
    mainProgram = "Cpp2IL";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
