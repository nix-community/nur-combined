{ iosevka }:

{
  minoko = iosevka.override {
    privateBuildPlan = builtins.readFile ./iosevka-minoko.toml;
    set = "minoko";
  };
  aile-minoko = iosevka.override {
    privateBuildPlan = builtins.readFile ./iosevka-aile-minoko.toml;
    set = "aile-minoko";
  };
}
