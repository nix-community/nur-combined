{
  pkgs,
  lib,
  config,
  ...
}:
let
  weechat-pkg = pkgs.weechat.override {
    configure =
      { availablePlugins, ... }:
      {
        plugins = with availablePlugins; [
          python
          perl
          ruby
          lua
        ];

        scripts = with pkgs.weechatScripts; [
          autosort
          weechat-grep
          buffer_autoset
          highmon
          weechat-go
          edit
          multiline
          url_hint
          wee-slack
        ];
      };
  };
in
{
  options.dots.irc.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the IRC dotfiles module.";
  };

  config = lib.mkIf config.dots.irc.enable {
    home.packages = [
      weechat-pkg
    ];
    programs.senpai = {
      enable = true;
      config = {
        address = "irc.avyay.in";
        nickname = "avy";
        password-cmd = [
          "cat"
          config.sops.secrets.soju_password.path
        ];
      };
    };
  };
}
