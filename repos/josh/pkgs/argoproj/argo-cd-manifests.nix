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
  version = "3.4.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "argoproj";
    repo = "argo-cd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dpn4KHKs766/cmh0gLwaFExQ2tMRbdXZK+2v2jM3iF8=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/manifests/. $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

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
    description = "Argo CD Kubernetes manifests";
    homepage = "https://argo-cd.readthedocs.io/en/stable/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
