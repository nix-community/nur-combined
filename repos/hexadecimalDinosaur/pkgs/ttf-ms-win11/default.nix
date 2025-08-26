{ pkgs, ... }:
let
  derivation = pkgs.callPackage ./package.nix { };
  lists = import ./lists.nix;
in
{
  default = derivation;
  japanese = derivation.override {
    pname-suffix = "-japanese";
    desc-suffix = " (Japanese)";
    fonts = lists.japanese;
  };
  korean = derivation.override {
    pname-suffix = "-korean";
    desc-suffix = " (Korean)";
    fonts = lists.korean;
  };
  sea = derivation.override {
    pname-suffix = "-sea";
    desc-suffix = " (Southeast Asian)";
    fonts = lists.sea;
  };
  thai = derivation.override {
    pname-suffix = "-thai";
    desc-suffix = " (Thai)";
    fonts = lists.thai;
  };
  zh-cn = derivation.override {
    pname-suffix = "-zh-cn";
    desc-suffix = " (Simplified Chinese)";
    fonts = lists.zh-cn;
  };
  zh-tw = derivation.override {
    pname-suffix = "-zh-tw";
    desc-suffix = " (Traditional Chinese)";
    fonts = lists.zh-tw;
  };
  other = derivation.override {
    pname-suffix = "-other";
    desc-suffix = " (Other)";
    fonts = lists.other;
  };
  all = derivation.override {
    pname-suffix = "-all";
    desc-suffix = " (All)";
    fonts = lists.all;
  };
}
