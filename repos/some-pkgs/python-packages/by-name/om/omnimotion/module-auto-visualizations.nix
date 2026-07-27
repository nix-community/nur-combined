{ config, lib, runVisualizer, ... }: with lib; with lib.types; {
  options.visualizations = mkOption { type = attrsOf package; };
  config.visualizations = lib.genAttrs
    (builtins.attrNames config.examples)
    (name:
      let example = config.examples.${name}.package;
      in
      runVisualizer
        {
          checkpoint = "${example}/model*.pth";
          dataDir = "${example}";
          maskPath = "${example}/mask_0.png";
        });
}
