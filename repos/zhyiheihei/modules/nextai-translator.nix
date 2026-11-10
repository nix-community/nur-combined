# NextAI Translator 划词翻译桌面端 NixOS 模块主体。
# 本模块随 zhyi-packages 发布，由上层 flake（nixos-config 的
# nixos/client-apps/nextai-translator.nix 薄壳）导入后启用；包定义在
# ../pkgs/uncategorized/nextai-translator，逻辑不重复落在上层仓库。
self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.nextai-translator;
in
{
  options.lantian.nextai-translator = {
    enable = lib.mkEnableOption "NextAI Translator, a ChatGPT API powered selection translation desktop app";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.nextai-translator;
      defaultText = lib.literalExpression "zhyi-packages.packages.\${pkgs.system}.nextai-translator";
      description = "The NextAI Translator package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform cfg.package) cfg.package;
  };
}
