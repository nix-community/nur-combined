{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  yq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "argo-cd-manifests";
  version = "3.5.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "argoproj";
    repo = "argo-cd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lhxdpz/Mjg0zZpktJD6yBCNoL5aPtemJoSCQvKkBqsw=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/manifests/. $out/
  '';

  # The regex excludes upstream's rolling "stable" tag
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex=^v([0-9][0-9.]*)$"
    ];
  };

  passthru.tests = {
    parse =
      runCommand "test-argo-cd-manifests-parse"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ yq ];
        }
        ''
          yq -r '.kind? // empty' ${finalAttrs.finalPackage}/install.yaml >kinds.txt
          grep -q . kinds.txt
          yq -r '.kind? // empty' ${finalAttrs.finalPackage}/namespace-install.yaml >kinds.txt
          grep -q . kinds.txt
          touch $out
        '';
  };

  meta = {
    description = "Kubernetes manifests for Argo CD, a declarative GitOps continuous delivery tool for Kubernetes";
    homepage = "https://argo-cd.readthedocs.io/en/stable/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
