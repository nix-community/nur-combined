{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
 buildDotnetModule(finalAttrs: {

  pname = "x4-xmldiff";
  version = "0.2.28";

  src = fetchFromGitHub {
    owner = "chemodun";
    repo = "X4-XMLDiffAndPatch";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3yd6s10De79fAwN4JGJEWbXMMCDbPNyvZTqGI0mBJaU=";
  };

  projectFile = "XMLDiffAndPatch.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  executables = [ "XMLDiff" "XMLPatch" ];

  meta = {
    changelog = "https://github.com/chemodun/X4-XMLDiffAndPatch/releases/tag/v${finalAttrs.version}";
    description = "Simple XML diff and patch tools for X4: Foundations";
    homepage = "https://github.com/chemodun/X4-XMLDiffAndPatch";
    license = lib.licenses.mit;
    mainProgram = "XMLDiff";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
