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
