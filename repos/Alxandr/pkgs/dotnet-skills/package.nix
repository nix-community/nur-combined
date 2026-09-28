{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "b649b55a32cbd5ba32964e818bb0799ed3bcbbcd";
    sha256 = "sha256-FDzQJviAGFr6g26ZDG/06CWPP2fuL7VU4MR8bSANu68=";
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
