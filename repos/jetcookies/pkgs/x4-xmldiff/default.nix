{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
 buildDotnetModule(finalAttrs: {

  pname = "x4-xmldiff";
  version = "0.2.27";

  src = fetchFromGitHub {
    owner = "chemodun";
    repo = "X4-XMLDiffAndPatch";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SHTb2rq3VNzC0LI0JJ7T6y4CDp1IbpsDnFAuKADMBOk=";
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
