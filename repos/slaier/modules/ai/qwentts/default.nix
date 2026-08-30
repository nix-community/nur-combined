{
  pkgs,
  ...
}:
let
  talkerModel = pkgs.fetchurl {
    url = "https://huggingface.co/Serveurperso/Qwen3-TTS-GGUF/resolve/main/qwen-talker-0.6b-customvoice-Q4_K_M.gguf";
    hash = "sha256-s6fmYT2A+KcDwGJn/B6U1IzpGTKrgqtuMcUPTKSGjh4=";
  };
  codecModel = pkgs.fetchurl {
    url = "https://huggingface.co/Serveurperso/Qwen3-TTS-GGUF/resolve/main/qwen-tokenizer-12hz-Q4_K_M.gguf";
    hash = "sha256-zzeItNUKqmZftuV8FwOWquA6NVX+pS0rXQzakC1lgDk=";
  };
in
{
  imports = [ ./module.nix ];

  services.qwentts = {
    enable = true;
    settings = {
      model = talkerModel;
      codec = codecModel;
      port = 8088;
      alias = "qwen3-tts";
      lang = "Chinese";
      sleep-idle-seconds = 600;
    };
    openFirewall = false;
  };

  environment.systemPackages = [ pkgs.qwentts ];
}
