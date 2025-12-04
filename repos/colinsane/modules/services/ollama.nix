# ollama: <https://github.com/ollama/ollama>
# - <https://wiki.nixos.org/wiki/Ollama>
#
# use: `ollama run llama3.2`
# - list available: `ollama list`
# - use a remote session: <https://github.com/ggozad/oterm>
#
# models have to be explicitly downloaded. see `ollamaPackages` for examples.
# should ollamaPackages not suffice, `ollama pull llama3.2` should fetch a model,
# but the service will need modification to allow net access first.
#
# models are defined e.g. here: <https://ollama.com/library/llama3.2:3b/blobs/dde5aa3fc5ff>
#
### to confirm GPU acceleration
# grep `journalctl -u ollama` for:
# - `looking for compatible GPUs`
# and see if it says anything bad afterward like:
# - `no compatible GPUs were discovered`
# then run a model and check for:
# `offloading <n> repeating layers to GPU`
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.ollama;
  modelSources = pkgs.symlinkJoin {
    name = "ollama-models";
    paths = with pkgs.ollamaPackages; [
      athene-v2-72b-q2_K  # very knowledgable; fairly compliant (briefly lets you know if something's wrong, but still answers)
      # aya-8b  # it avoids generating code, only text
      # codegeex4-9b  # it's okaaay, seems to not give wrong code, just incomplete code.
      # codegemma-7b  # it generates invalid nix code
      codestral-22b
      # deepseek-coder-7b  # subpar to deepseek-coder-v2 in nearly every way
      deepseek-coder-v2-16b  # GREAT balance between speed and code quality. code is superior to qwen2_5 in some ways, and inferior in others
      # deepseek-coder-v2-16b-lite-instruct-q5_1  # higher-res version of default 16b (but in practice, is more rambly and less correct)
      deepseek-r1-1_5b
      deepseek-r1-7b
      deepseek-r1-14b
      # deepseek-r1-32b  # redundant with abliterated deepseek-r1
      # deepseek-r1-671b  # requires 443 GB of RAM
      deepseek-r1-abliterated-14b
      deepseek-r1-abliterated-32b
      deepseek-r1-abliterated-70b
      devstral-24b
      dolphin3-8b  # gives incorrect RDMA RoCEv2 UDP port
      # dolphin-mistral-7b  # UNCENSORED mistral; compliant
      # dolphin-mixtral-8x7b  # about as fast as a 14b model, similar quality results. uncensored, but still preachy
      # falcon2-11b  # code examples are lacking
      # gemma2-9b  # fast, but not great for code
      # gemma2-27b  # generates at 1word/sec, but decent coding results if you can wrangle it
      gemma3-12b
      gemma3-27b  # gives incorrect RDMA RoCEv2 UDP port
      gemma3n-e2b
      gemma3n-e4b
      # glm4-9b  # it generates invalid code
      gpt-oss-20b
      gpt-oss-120b
      # hermes3-8b  # FAST, but unwieldy
      # kimi-k2-1026b  # MoE with 32B activated parameters, 384 experts (requires 384 GiB RAM)
      # llama3-chatqa-8b  # it gets stuck
      # llama3_1-70b  # generates like 1 word/sec, decent output (comparable to qwen2_5-32b)
      # llama3_2-3b  # redundant with uncensored llama
      llama3_2-uncensored-3b
      # llama3_3-70b  # non-compliant; dodges iffy questions
      llama3_3-abliterated-70b  # compliant, but slower and not as helpful as deepseek-r1-abliterated-70b
      llama4-16x17b  # gives incorrect RDMA RoCEv2 UDP port
      magicoder-7b  # it generates valid, if sparse, code
      magistral-24b
      marco-o1-7b  # untested
      # mistral-7b  # it generates invalid code
      # mistral-nemo-12b  # it generates invalid code
      # mistral-small-22b  # quality comparable to qwen2_5
      mistral-small3_2-24b
      # mistral-large-123b  # times out launch on desko
      # mixtral-8x7b  # generates valid, if sparse, code; only for the most popular languages
      olmo2-13b
      openthinker-7b
      openthinker-32b
      orca-mini-7b
      # phi3_5-3b  # generates invalid code
      phi4-14b
      # qwen2_5-7b   # notably less quality than 32b (i.e. generates invalid code)
      # qwen2_5-14b  # *almost* same quality to 32b variant, but faster
      qwen3-8b
      qwen3-14b  # gives correct RDMA RoCEv2 UDP port
      qwen3-30b
      # qwen2_5-32b-instruct-q2_K  # lower-res version of default 32b (so, slightly faster, but generates invalid code where the full res generates valid code)
      qwen2_5-32b  # generates 3~5 words/sec, but notably more accurate than coder-7b
      qwen2_5-abliterate-7b
      qwen2_5-abliterate-14b
      qwen2_5-abliterate-32b
      # qwen2_5-coder-7b  # fast, and concise, but generates invalid code
      # qwq-32b  # heavily restricted
      qwq-abliterated-32b
      # solar-pro-22b  # generates invalid code
      # starcoder2-15b-instruct  # it gets stuck
      # wizardlm2-7b  # generates invalid code
      # yi-coder-9b  # subpar to qwen2-14b, but it's still useful
    ];
  };
  models = "${modelSources}/share/ollama/models";
in
{
  options.sane.services.ollama = with lib; {
    enable = mkEnableOption "ollama Large Language Model";
  };

  config = lib.mkIf (cfg.enable && config.sane.maxBuildCost >= 3) {
    services.ollama.enable = true;
    services.ollama.user = "ollama";
    services.ollama.group = "ollama";
    services.ollama.models = models;
    services.ollama.host = "0.0.0.0";  # TODO: specify specifically 127.0.0.1 and 10.0.10.22

    # these acceleration settings are relevant to `desko`.
    services.ollama.package = lib.mkIf config.hardware.amdgpu.opencl.enable pkgs.ollama-rocm;  # AMD GPU acceleration (achieves the same as `nixpkgs.config.rocmSupport = true` but just for ollama (the global toggle rebuilds the world))
    services.ollama.rocmOverrideGfx = "10.1.0";  #< `nix-shell -p "rocmPackages.rocminfo" --run "rocminfo" | grep "gfx"`  (e.g. gfx1010)
    services.ollama.environmentVariables.HCC_AMDGPU_TARGET = "gfx1010";

    users.groups.ollama = {};

    users.users.ollama = {
      group = "ollama";
      isSystemUser = true;
    };

    systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;  #< not required, but DynamicUser is confusing
    # `ollama run` connects to the ollama service over IP,
    # but other than that networking isn't required for anything but downloading models.
    systemd.services.ollama.serviceConfig.IPAddressDeny = "any";
    systemd.services.ollama.serviceConfig.IPAddressAllow = [
      "10.0.10.0/24"
      "127.0.0.1"
    ];

    sane.ports.ports."11434" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;  #< TODO: restrict to just wireguard clients
      description = "colin-ollama";
    };
  };
}
