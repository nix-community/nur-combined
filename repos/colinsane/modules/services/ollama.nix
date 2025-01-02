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
# TODO: enable ShellGPT integration?
# - <https://github.com/TheR1D/shell_gpt?tab=readme-ov-file#docker--ollama>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.ollama;
  modelSources = pkgs.symlinkJoin {
    name = "ollama-models";
    paths = with pkgs.ollamaPackages; [
      athene-v2-72b-q2_K  # untested
      # aya-8b  # it avoids generating code, only text
      # codegeex4-9b  # it's okaaay, seems to not give wrong code, just incomplete code.
      # codegemma-7b  # it generates invalid nix code
      codestral-22b
      # deepseek-coder-7b  # subpar to deepseek-coder-v2 in nearly every way
      deepseek-coder-v2-16b  # GREAT balance between speed and code quality. code is superior to qwen2_5 in some ways, and inferior in others
      # deepseek-coder-v2-16b-lite-instruct-q5_1  # higher-res version of default 16b (but in practice, is more rambly and less correct)
      # falcon2-11b  # code examples are lacking
      # gemma2-9b  # fast, but not great for code
      gemma2-27b  # generates at 1word/sec, but decent coding results if you can wrangle it
      # glm4-9b  # it generates invalid code
      # hermes3-8b  # FAST, but unwieldy
      # llama3-chatqa-8b  # it gets stuck
      # llama3_1-70b  # generates like 1 word/sec, decent output (comparable to qwen2_5-32b)
      llama3_2-3b
      magicoder-7b  # it generates valid, if sparse, code
      marco-o1-7b  # untested
      # mistral-7b  # it generates invalid code
      # mistral-nemo-12b  # it generates invalid code
      mistral-small-22b  # quality comparable to qwen2_5
      # mistral-large-123b  # times out launch on desko
      # mixtral-8x7b  # generates valid, if sparse, code; only for the most popular languages
      # phi3_5-3b  # generates invalid code
      # qwen2_5-7b   # notably less quality than 32b (i.e. generates invalid code)
      qwen2_5-14b  # *almost* same quality to 32b variant, but faster
      # qwen2_5-32b-instruct-q2_K  # lower-res version of default 32b (so, slightly faster, but generates invalid code where the full res generates valid code)
      qwen2_5-32b  # generates 3~5 words/sec, but notably more accurate than coder-7b
      # qwen2_5-coder-7b  # fast, and concise, but generates invalid code
      qwq-32b  # untested
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

  config = lib.mkIf cfg.enable {
    services.ollama.enable = true;
    services.ollama.user = "ollama";
    services.ollama.group = "ollama";
    services.ollama.models = models;

    # these acceleration settings are relevant to `desko`.
    services.ollama.acceleration = lib.mkIf config.hardware.amdgpu.opencl.enable "rocm";  # AMD GPU acceleration (achieves the same as `nixpkgs.config.rocmSupport = true` but just for ollama)
    services.ollama.rocmOverrideGfx = "10.1.0";  #< `nix-shell -p "rocmPackages.rocminfo" --run "rocminfo" | grep "gfx"`
    # services.ollama.environmentVariables.HCC_AMDGPU_TARGET = "gfx1010";  # seems to be unnecessary

    users.groups.ollama = {};

    users.users.ollama = {
      group = "ollama";
      isSystemUser = true;
    };

    systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;  #< not required, but DynamicUser is confusing
    # `ollama run` connects to the ollama service over IP,
    # but other than that networking isn't required for anything but downloading models.
    systemd.services.ollama.serviceConfig.IPAddressDeny = "any";
    systemd.services.ollama.serviceConfig.IPAddressAllow = "127.0.0.1";
  };
}
