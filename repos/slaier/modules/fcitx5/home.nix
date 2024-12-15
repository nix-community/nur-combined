{ pkgs, config, ... }:
let
  makeDict = name: dicts:
    let
      body = builtins.toJSON {
        inherit name;
        version = "1.0";
        sort = "by_weight";
        use_preset_vocabulary = false;
        import_tables = dicts;
      };
    in
    ''
      # Rime dictionary
      # encoding: utf-8
      ---
      ${body}
      ...
    '';
in
{
  xdg.configFile."fcitx5/profile" = {
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=rime

      [Groups/0/Items/0]
      # Name
      Name=rime
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
    force = true;
  };
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.nur.repos.xddxdd.fcitx5-breeze}/share/fcitx5/themes";
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        schema_list = [ ({ schema = "aurora_pinyin"; }) ];
        "menu/page_size" = 9;
        "ascii_composer/good_old_caps_lock" = true;
        "ascii_composer/switch_key" = {
          "Caps_Lock" = "noop";
          "Shift_L" = "commit_code";
          "Shift_R" = "commit_code";
          "Control_L" = "noop";
          "Control_R" = "noop";
        };
        "switcher/hotkeys" = [ "F4" ];
        "switcher/save_options" = [ "full_shape" "ascii_punct" "simplification" "extended_charset" ];
        "switcher/fold_options" = false;
        "switcher/abbreviate_options" = false;
      };
    };

    "fcitx5/rime/aurora_pinyin.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian_aurora_pinyin";
        "__include" = "emoji_suggestion:/patch";
        punctuator = {
          import_preset = "symbols";
          half_shape = {
            "#" = "#";
            "*" = "*";
            "~" = "~";
            "=" = "=";
            "`" = "`";
          };
        };
      };
    };

    "fcitx5/rime/lantian_aurora_pinyin.dict.yaml".text = makeDict
      "lantian_aurora_pinyin"
      [
        "aurora_pinyin"
        "moegirl"
        "zhwiki"
      ];

    "fcitx5/rime/luna_pinyin_simp.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian_luna_pinyin_simp";
        "__include" = "emoji_suggestion:/patch";
        punctuator = {
          import_preset = "symbols";
          half_shape = {
            "#" = "#";
            "*" = "*";
            "~" = "~";
            "=" = "=";
            "`" = "`";
          };
        };
      };
    };

    "fcitx5/rime/lantian_luna_pinyin_simp.dict.yaml".text = makeDict
      "lantian_luna_pinyin_simp"
      [
        "pinyin_simp"
        # "moegirl"
        # "zhwiki"
        "luna_pinyin.anime"
        "luna_pinyin.basis"
        "luna_pinyin.biaoqing"
        "luna_pinyin.chat"
        "luna_pinyin.classical"
        # "luna_pinyin.cn_en"
        "luna_pinyin.computer"
        "luna_pinyin.daily"
        "luna_pinyin.diet"
        "luna_pinyin.game"
        "luna_pinyin.gd"
        "luna_pinyin.hanyu"
        "luna_pinyin.history"
        "luna_pinyin.idiom"
        "luna_pinyin.moba"
        "luna_pinyin.movie"
        "luna_pinyin.music"
        "luna_pinyin.name"
        "luna_pinyin.net"
        "luna_pinyin.poetry"
        "luna_pinyin.practical"
        "luna_pinyin.sougou"
        "luna_pinyin.website"
      ];
  };
}
