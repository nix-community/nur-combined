{
  flake.modules.nixos.ipex = {
    virtualisation.oci-containers.containers.ipex-llm-container = {
      image = "intelanalytics/ipex-llm-inference-cpp-xpu:2.1.0-SNAPSHOT";
      volumes = [ "/var/lib/ollama:/models" ];
      environment = {
        DEVICE = "Arc";
        no_proxy = "localhost,127.0.0.1";
        OLLAMA_ORIGINS = "http://192.168.*";
        SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS = "1";
        ONEAPI_DEVICE_SELECTOR = "level_zero:0";
        OLLAMA_HOST = "[::]:11434";
      };
      devices = [ "/dev/dri:/dev/dri:rwm" ];
      cmd = [
        "/bin/sh"
        "-c"
        "chmod +x /llm/scripts/start-ollama.sh && /llm/scripts/start-ollama.sh && echo 'Startup script finished, container is now idling.' && sleep infinity"
      ];
      extraOptions = [
        "--net=host"
        "--memory=32G"
        "--shm-size=16g"
      ];
    };
  };
}
