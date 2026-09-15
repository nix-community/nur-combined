{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "26323a52990d0cbfc838117109b40e115aac891f";
    sha256 = "sha256-h2rb0bv9LcV9j4AYKRfHa9Qgv08HRFttewOgYDPcJpQ=";
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
