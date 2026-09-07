{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-09-04";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "ac8f41264bdd557e58924a3110eea8e0917dcf4d";
    sha256 = "sha256-39aJOQMdnqWw8CgDGVmyhOLGV2vrbVTvTxMq+secczY=";
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
