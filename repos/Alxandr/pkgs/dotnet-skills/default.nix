{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "4ecd7d9c76fa458807684771c2bfc7acf1e00ad3";
    sha256 = "sha256-rKQi0N1WdnK6VM8Z1YVGMipropBMoGpGdVH1siCsvCY=";
  };

  marketplace = ./marketplace.json;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
      "--version-regex"
      "^0-(.*)$"
    ];
  };

  meta = {
    description = ".NET Agent Skills";
    homepage = "https://github.com/dotnet/skills";
    license = lib.licenses.mit;
  };
})
