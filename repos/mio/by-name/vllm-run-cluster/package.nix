/*
  Usage:

  Head node:

  nix run git+https://github.com/mio-19/nurpkgs.git#vllm-run-cluster -- \
    vllm/vllm-openai \
    <HEAD_NODE_IP> \
    --head \
    /path/to/the/huggingface/home/in/this/node \
    --cap-add=CAP_SYS_ADMIN \
    -e VLLM_HOST_IP=<HEAD_NODE_IP>

  Worker node:

  nix run git+https://github.com/mio-19/nurpkgs.git#vllm-run-cluster -- \
    vllm/vllm-openai \
    <HEAD_NODE_IP> \
    --worker \
    /path/to/the/huggingface/home/in/this/node \
    --cap-add=CAP_SYS_ADMIN \
    -e VLLM_HOST_IP=<WORKER_NODE_IP>

  Reference:
  https://docs.vllm.ai/en/stable/serving/parallelism_scaling/#what-is-ray

  Notes from the vLLM docs:
  - This helper starts containers across nodes and initializes Ray.
  - Add --cap-add=CAP_SYS_ADMIN if you need GPU performance counters for
    profiling or tracing.
  - VLLM_HOST_IP must be unique for each worker.
  - Keep the launching shells open; closing one terminates that Ray node and
    can shut down the cluster.
  - Ensure all nodes can communicate with each other over their supplied IPs.
*/
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
