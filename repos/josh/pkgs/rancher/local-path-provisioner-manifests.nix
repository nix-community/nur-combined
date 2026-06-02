{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "local-path-provisioner-manifests";
  version = "0.0.36";

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "local-path-provisioner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pMcyabGJEdlV+CvdCjm0JcXUvWyNkdJRPEzVKIK7xOo=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/deploy/{local-path-storage,provisioner}.yaml $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Dynamically provisioning persistent local storage with Kubernetes";
    homepage = "https://github.com/rancher/local-path-provisioner";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
