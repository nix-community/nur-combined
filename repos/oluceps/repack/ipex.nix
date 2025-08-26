{
  reIf,
  ...
}:
reIf {
  virtualisation.oci-containers.containers.ipex-llm-container = {

    image = "intelanalytics/ipex-llm-inference-cpp-xpu:latest";

    volumes = [ "/var/lib/ollama:/models" ];
    # # pull = "always";
    # # privileged = true;
    environment = {
      DEVICE = "Arc";
      no_proxy = "localhost,127.0.0.1";
      OLLAMA_ORIGINS = "http://192.168.*";
      SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS = "1";
      ONEAPI_DEVICE_SELECTOR = "level_zero:0";
      OLLAMA_HOST = "[::]:11434";
      # SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS = "1";
      # IPEX_LLM_SCHED_MAX_COPIES = "1";
      # IPEX_LLM_QUANTIZE_KV_CACHE = "1";
      # FLASH_MOE_EP = "1";
      # CORES = "20";
      # KMP_AFFINITY = "granularity=fine,proclist=[0,2-20],explicit";
      # KMP_BLOCKTIME = "200";
    };
    devices = [
      "/dev/dri:/dev/dri:rwm"
    ];
    cmd = [
      "/bin/sh"
      "-c"
      "/llm/scripts/start-ollama.sh && echo 'Startup script finished, container is now idling.' && sleep infinity"
      # "sleep infinity"
    ];
    extraOptions = [
      "--net=host"
      "--memory=32G"
      "--shm-size=16g"
    ];
  };
}
