{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go_1_27,
  nix-update-script,
  runCommand,
}:
# Remove go 1.27 workaround once nixpkgs defaults to go 1.27 or newer.
(buildGoModule.override { go = go_1_27; }) (finalAttrs: {
  pname = "intel-gpu-plugin";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-device-plugins-for-kubernetes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8sUag2GCxwug2HhyxFQrNPt9wIp7mhspIkZNs9+Cqe0=";
  };

  vendorHash = "sha256-37g8gQD5tKp6zAZPc6BFvboBA/07YDwHw51K25oSc78=";

  subPackages = [ "cmd/gpu_plugin" ];

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  passthru.tests = {
    help =
      runCommand "test-intel-gpu-plugin-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          gpu_plugin -h 2>output.txt || true
          grep --quiet -- "-shared-dev-num" output.txt
          grep --quiet -- "-allocation-policy" output.txt
          touch $out
        '';
  };

  meta = {
    description = "Kubernetes device plugin advertising Intel GPUs as gpu.intel.com/i915 resources";
    homepage = "https://github.com/intel/intel-device-plugins-for-kubernetes";
    license = lib.licenses.asl20;
    mainProgram = "gpu_plugin";
    platforms = lib.platforms.linux;
  };
})
