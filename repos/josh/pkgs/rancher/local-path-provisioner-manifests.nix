{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  yq,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "local-path-provisioner-manifests";
  version = "0.0.36";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "local-path-provisioner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pMcyabGJEdlV+CvdCjm0JcXUvWyNkdJRPEzVKIK7xOo=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/deploy/{local-path-storage,provisioner}.yaml $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    parse =
      runCommand "test-local-path-provisioner-manifests-parse"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ yq ];
        }
        ''
          find ${finalAttrs.finalPackage} -name '*.yaml' -exec yq -r '.kind? // empty' {} + | grep -q .
          touch $out
        '';
  };

  meta = {
    description = "Dynamically provisioning persistent local storage with Kubernetes";
    homepage = "https://github.com/rancher/local-path-provisioner";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
