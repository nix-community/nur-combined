{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "local-path-provisioner-chart";
  version = "0.0.37";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "local-path-provisioner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H/YuDKAXmh8TpkSuIo/v1v12mxmO2qWOCB638PSdLEs=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/deploy/chart/local-path-provisioner/. $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    files =
      runCommand "test-local-path-provisioner-chart-files"
        {
          __structuredAttrs = true;
        }
        ''
          diff -r ${finalAttrs.src}/deploy/chart/local-path-provisioner ${finalAttrs.finalPackage}
          touch $out
        '';

    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "local-path-provisioner";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Dynamically provisioning persistent local storage with Kubernetes";
    homepage = "https://github.com/rancher/local-path-provisioner";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
