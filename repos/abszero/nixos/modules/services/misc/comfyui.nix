{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.comfyui;
  comfyuiCfg = config.services.comfyui;
in

{
  # TODO: migrate to nixpkgs when custom nodes are supported
  disabledModules = [ "services/misc/comfyui.nix" ];

  options.abszero.services.comfyui.enable = mkEnableOption "comfyui generative AI frontend";

  config.services = mkIf cfg.enable {
    comfyui = {
      enable = true;
      extraFlags = [
        "--highvram"
        "--use-pytorch-cross-attention"
        "--enable-triton-backend"
      ];
      customNodes = with pkgs; [
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
    tailscale.serve.services.comfyui.endpoints."tcp:80" =
      "http://127.0.0.1:${toString comfyuiCfg.port}";
  };
}
