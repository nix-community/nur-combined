{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "9864ca798f9448ef954ad1f05baf0dfca6501d51";
    sha256 = "sha256-Dg8+YGmbMY7nfT/FnFCyjDkh33nlRpS/jBtjA8YQOUM=";
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
