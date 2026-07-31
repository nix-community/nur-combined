{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  yq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "external-snapshotter-manifests";
  version = "8.6.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kubernetes-csi";
    repo = "external-snapshotter";
    tag = "v${finalAttrs.version}";
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

  # The regex excludes upstream's parallel client/vX.Y.Z release namespace
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex=^v([0-9][0-9.]*)$"
    ];
  };

  passthru.tests = {
    parse =
      runCommand "test-external-snapshotter-manifests-parse"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ yq ];
        }
        ''
          find ${finalAttrs.finalPackage} -name '*.yaml' -exec yq -r '.kind? // empty' {} + >kinds.txt
          grep -q . kinds.txt
          touch $out
        '';
  };

  meta = {
    description = "Kubernetes CSI external-snapshotter CRDs and snapshot-controller manifests";
    homepage = "https://github.com/kubernetes-csi/external-snapshotter";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
