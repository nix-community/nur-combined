# ZCode NixOS 模块主体。
# 本模块随 zhyi-packages 发布，由上层 flake（nixos-config 的
# nixos/client-apps/zcode.nix 薄壳）导入后启用；包定义在
# ../pkgs/uncategorized/zcode，逻辑不重复落在上层仓库。
{
  self,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.zcode;
in
{
  options.lantian.zcode = {
    enable = lib.mkEnableOption "ZCode, Z.ai's official agentic development environment desktop app";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.zcode;
      defaultText = lib.literalExpression "zhyi-packages.packages.\${pkgs.system}.zcode";
      description = "The ZCode package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (
      lib.meta.availableOn pkgs.stdenv.hostPlatform cfg.package
    ) cfg.package;
  };
}
