{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "95e7d0cb7994d47b5789baa68e13f7a2f348b956";
    sha256 = "sha256-EJeF8f3uGaay5ZDD2/1Zy//KJt9cExDV0vEvb8rkj98=";
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
