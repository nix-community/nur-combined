# useful commands:
# - `curl http://10.0.10.22:11435/models | jq .`
# - `sudo radeontop`
# - `BUNPEN_DISABLE=1 sudo -E htop` (and view `GPU` column, to see usage)
#
# ## performance tuning:
# - run `llama-server --verbose ...`
# - GPU use (per htop) should be near 100% during the prompt processing (i.e. the first prompt after init).
#   - even for models larger than the GPU device ram, it seems.
# - check logs for: `load_tensors: offloaded NN/MM layers to GPU`
#
# ## docs
# - tool calling, chat templates: <https://github.com/ggml-org/llama.cpp/blob/master/docs/function-calling.md>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.llama-cpp;
in
{
  options.sane.services.llama-cpp = {
    enable = lib.mkEnableOption "llama-cpp LLM server";
  };

  config = lib.mkIf (cfg.enable && config.sane.maxBuildCost >= 2) {
    services.llama-cpp.enable = true;
    # services.llama-cpp.package = pkgs.llama-cpp-vulkan;
    services.llama-cpp.package = pkgs.llama-cpp-latest.override { vulkanSupport = true; };
    # services.llama-cpp.package = pkgs.llama-cpp.override { cpuArchDynamicDispatch = false; vulkanSupport = true; };
    services.llama-cpp.settings = {
      verbose = true;
      host = config.sane.hosts.by-name."${config.networking.hostName}".wg-home.ip;
      # port: default is 8080, conflict-prone.
      # ollama default is 11434. hence 11435, as the successor.
      port = 11435;
      models-dir = "${pkgs.llama-cpp-models}";
      models-preset = "${pkgs.llama-cpp-models}/presets.ini";

      # Decode-first defaults measured on desko with Qwen3.6-35B-A3B.
      # device = "none" => disables GPU. GPU is < 50% as performant for prompt processing than CPU.
      # the cost of disabling GPU is that text generation rate decreases as context increases.
      # below 32k tokens, CPU clearly outperforms; above 64k, GPU outperforms.
      device = "none";
      numa = "numactl";
      threads = 48;
      threads-batch = 48;
      # XXX(2026-11-22): flash attention destroys CPU decode speed by up to 35%. 
      flash-attn = "off";
      # XXX(2026-11-22): default of 4 parallel slots decreases decode speed by 10-20% _even when only one slot is active_.
      parallel = 1;

      # XXX(2026-04-01): if omitted, llama-cpp will attempt the model's native context, and decrease until it fits into RAM.
      # ctx-size = 131072;
      # ctx-size = 65536;
      # fit-target: how many MiB to leave free, for unexpected allocations (default 1024 MiB)
      fit-target = 128;
      # fit-ctx: never reduce context below this level when fitting to ram
      # fit-ctx = 32768;
      fit-ctx = 131072;
      # swa-full seems to allow much faster prompt evals after the first system prompt is cached,
      # but not always supported by model -- check logs:
      # > srv    load_model: swa_full is not supported by this model, it will be disabled
      # swa-full = true;
      cache-ram = 32768;  # prompt cache (applies iff swa-full not supported by model?). default is 8192 (MiB)
      # ctx-checkpoints = 128;  # experimental. each checkpoint is 50 MiB. defaults to 32 checkpoints.
      # ubatch-size is how many tokens to process simultaneously?
      # default: 512. higher values generally increase throughput, but also increase memory use.
      ubatch-size = 128;
      # cache-type-{k,v}: f32, f16, bf16, q8_0, q4_0, q4_1, iq4_nl (unsupported), q5_0, q5_1 (default: f16)
      # this refers to quantization of the k -> v (attention) cache.
      # quantizing k would seem to have larger effect than quantizing v.
      # jury's out on how much quantization degrades the model, however one would expect it to get worse as the context gets longer because it's recursive over all previous tokens.
      # <https://github.com/ggml-org/llama.cpp/discussions/20969#discussioncomment-16388331>
      # cache-k,v = f16,q8_0: used for 1 session. even this is enough to corrupt file paths (they become non-english): avoid.
      # cache-k,v = f16,q5_1: no data.
      # cache-k,v = q8_0,q8_0: no data.
      # cache-k,v = q8_0,q5_1: used for 1 session. started looping after 5~8k tokens.
      # cache-k,v = q5_1,q5_1: maybe a slight bias toward looping?
      # cache-type-k = "f16";
      # cache-type-v = "q8_0";
      no-warmup = true;  # faster load -> eval, by not feeding it a dummy prompt on load
      no-mmproj = true;  # don't load vision weights

      # coherence (keep the model from becoming pathological)
      # in actuality, tweaking DRY settings seems to induce typos in non-quantized models!
      # "--dry-multiplier" "0.6"  # how much influence the Don't Repeat Yourself filter has on overall token output (?)
      # "--dry-base" "2.0"  # exponential penalization ramp
      # "--dry-penalty-last-n" "512"
      # "--dry-sequence-breaker" "none"
      # "--dry-penalty-last-n" "512"
      # "--reasoning-budget" "1536"  # new models sometimes get stuck in <thought>...</thought> loops: force a maximum.
      # "--reasoning-format" "none"  # disable server-side parsing of <thought>...</thought>; let them show up inline.

      # TODO: potential performance optimizations:
      # "--slot-save-path" "PATH"  # persist KV cache to disk
      # "--lookup-cache-dynamic" "FNAME"
      # "--no-kv-offload"  # XXX(2026-04-01) this would SIGNIFICANTLY reduce GPU memory usage, but breaks Claude tool use: "failed to parse grammar".
      # "--spec-default"  # speculative decoding
      # "--no-host"
      # "--no-repack"
    };

    users.groups.llama-cpp = {};

    users.users.llama-cpp = {
      group = "llama-cpp";
      isSystemUser = true;
    };

    # bind to node 0 and use one hardware thread per physical core.
    # llama-cpp does not perform well in multi-socket mode; use node 0 for better locality with the GPU, where it's attached.
    # TODO: enable tensor-level parallelism and drop this -> 30% perf improvement. <https://github.com/ggml-org/llama.cpp/pull/32461>
    systemd.services.llama-cpp.serviceConfig.CPUAffinity = "0-127";
    systemd.services.llama-cpp.serviceConfig.NUMAPolicy = "bind";
    systemd.services.llama-cpp.serviceConfig.NUMAMask = "0";
    systemd.services.llama-cpp.serviceConfig.DynamicUser = lib.mkForce false;  # not required, but DynamicUser is confusing
    systemd.services.llama-cpp.serviceConfig.User = "llama-cpp";
    systemd.services.llama-cpp.environment.MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    # networking isn't required for anything but accepting client connections (wireguard),
    # or, maybe, downloading models.
    systemd.services.llama-cpp.serviceConfig.IPAddressDeny = "any";
    systemd.services.llama-cpp.serviceConfig.IPAddressAllow = [
      "10.0.10.0/24"
      "127.0.0.1"
    ];

    sane.persist.sys.byStore.private = [
      # mesa_shader_cache/ and radv_builtin_shaders/
      # otherwise these take a solid 10 minutes to build on first run!
      { user = "llama-cpp"; group = config.users.users.llama-cpp.group; path = "/var/cache/llama-cpp"; method = "bind"; }
    ];

    sane.ports.ports."11435" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;  # TODO: restrict to just wireguard clients
      description = "colin-llama-cpp";
    };
  };
}
