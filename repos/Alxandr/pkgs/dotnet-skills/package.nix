{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "e87c5da26cbf0f8c701e91247c4817df0adc12f7";
    sha256 = "sha256-nHa4gmLnD2qL4OMArmZBa6S4c+HMJq3AF37hgxC2ynw=";
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
