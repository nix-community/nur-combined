{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (audio-cpp-vulkan.override { models = [ "qwen3_asr" ]; })
  ];
}
