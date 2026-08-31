{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-08-28";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "d68dd70857076a17d4b418649bbcd20a315d59c3";
    sha256 = "sha256-lLpLorpWRmFcm2/e3rOrMyZdQbQJURbVFXhoclRZFk4=";
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
