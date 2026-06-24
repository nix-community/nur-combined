# Desktop running local AI
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) stdenvNoCC;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.desktopWithAI;
in

{
  imports = [ ./desktop.nix ];

  options.abszero.profiles.desktopWithAI.enable = mkEnableOption "AI-enabled desktop profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.desktop.enable = true;
      services.llama-cpp.enable = true;
      programs.crush.enable = true;
    };

    services = {
      comfyui = {
        enable = true;
        acceleration = "rocm";
        extraFlags = [
          "--highvram"
          "--use-pytorch-cross-attention"
          "--enable-triton-backend"
        ];
        customNodes = with pkgs; [
          comfyuiPackages.comfy-kitchen
          comfyui-anima-booster
          comfyui-manager
          comfyuiPackages.comfyui-res4lyf
          # Install dependencies for plugins managed by ComfyUI-Manager
          (stdenvNoCC.mkDerivation {
            name = "comfyui-custom-nodes-dependencies";
            src = emptyDirectory;
            propagatedBuildInputs =
              comfyuiPackages.comfyui-rgthree.propagatedBuildInputs ++ comfyui-lora-manager.propagatedBuildInputs;
          })
        ];
      };
      sillytavern.enable = true;
    };

    environment.systemPackages = with pkgs; [
      skills
    ];
  };
}
