{
  lib,
  stdenvNoCC,
  bash,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "vllm-run-cluster";
  version = "unstable-2024-11-21";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/vllm-project/vllm/bfde49e287cb5522fb0625c8e2b4e03cac20cbb2/examples/online_serving/run_cluster.sh";
    hash = "sha256-83oz6A4jHJxS+nyjuT+3X2P3sV/NXshg/MRTfMWgqus=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm0755 "$src" "$out/bin/run_cluster.sh"
    substituteInPlace "$out/bin/run_cluster.sh" \
      --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'

    runHook postInstall
  '';

  meta = {
    description = "Run the upstream vLLM Ray Docker cluster helper script";
    homepage = "https://docs.vllm.ai/en/stable/serving/parallelism_scaling/#what-is-ray";
    downloadPage = "https://github.com/vllm-project/vllm/blob/bfde49e287cb5522fb0625c8e2b4e03cac20cbb2/examples/online_serving/run_cluster.sh";
    license = lib.licenses.asl20;
    mainProgram = "run_cluster.sh";
    maintainers = [ ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
