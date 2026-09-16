{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {

  pname = "x4-xmldiff";
  version = "1.2.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "chemodun";
    repo = "X4-XMLDiffAndPatch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q5ymJ03WMHSiVupZQEr+DRrG14w6ENcNAVYUycwftwo=";
  };

  projectFile = "XMLDiffAndPatch.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  executables = [
    "XMLDiff"
    "XMLPatch"
  ];

  # XMLDiff and XMLPatch both reference XMLDiffAndPatch.Core, and MSBuild builds
  # the projects of a solution in parallel. Two build nodes then race to create
  # XMLDiffAndPatch.Core.deps.json, which intermittently fails with
  # "MSB4018: The process cannot access the file '.../XMLDiffAndPatch.Core.deps.json'
  # because it is being used by another process". With a single MSBuild node the
  # race cannot happen.
  #
  # Upstream issue (still open since 2019, fixed by msbuild /m:1):
  #   https://github.com/dotnet/sdk/issues/2902
  # Same class of bug in nixpkgs (parallel solution publish racing on shared DLLs):
  #   https://github.com/NixOS/nixpkgs/pull/540119
  enableParallelBuilding = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/chemodun/X4-XMLDiffAndPatch/releases/tag/${finalAttrs.src.tag}";
    description = "Simple XML diff and patch tools for X4: Foundations";
    homepage = "https://github.com/chemodun/X4-XMLDiffAndPatch";
    license = lib.licenses.mit;
    mainProgram = "XMLDiff";
    inherit (finalAttrs.dotnet-sdk.meta) platforms;
  };
})
