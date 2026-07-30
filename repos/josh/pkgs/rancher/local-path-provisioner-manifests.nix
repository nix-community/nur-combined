{
  lib,
  stdenvNoCC,
  nur,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "local-path-provisioner-manifests";
  inherit (nur.repos.josh.local-path-provisioner-chart) version src;

  __structuredAttrs = true;

  buildCommand = ''
    mkdir $out
    cp -R $src/deploy/{local-path-storage,provisioner}.yaml $out/
  '';

  passthru.tests = {
    parse =
      runCommand "test-local-path-provisioner-manifests-parse"
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
    description = "Dynamically provisioning persistent local storage with Kubernetes";
    homepage = "https://github.com/rancher/local-path-provisioner";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
