{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "external-snapshotter-manifests";
  version = "8.6.0";

  src = fetchFromGitHub {
    owner = "kubernetes-csi";
    repo = "external-snapshotter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9WSflI44XhecRqBWGKDfeMMHqOBwyInX9w2qMLDPylA=";
  };

  buildCommand = ''
    mkdir $out
    cp \
      $src/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml \
      $src/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml \
      $src/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml \
      $src/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml \
      $src/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml \
      $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Kubernetes CSI external-snapshotter CRDs and snapshot-controller manifests";
    homepage = "https://github.com/kubernetes-csi/external-snapshotter";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
