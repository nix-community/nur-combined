{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs) writeShellScript;
  inherit (lib) mkOption types;
in
{
  options.services.espanso.custom.replace = {
    date = mkOption { type = types.attrsOf types.str; };
    sequence = mkOption { type = types.attrsOf types.str; };
    word = mkOption { type = types.attrsOf types.str; };
    command = mkOption { type = types.attrsOf types.str; };
  };
  config = {
    systemd.user.services.espanso.Service.Environment = [
      "PATH=${config.home.homeDirectory}/.nix-profile/bin"
    ];
    services.espanso = {
      matches.default.matches =
        [ ]
        ++ (lib.pipe config.services.espanso.custom.replace.date [
          (builtins.mapAttrs (
            k: v: {
              trigger = k;
              replace = "{{date}}";
              vars = [
                {
                  name = "date";
                  type = "date";
                  params = {
                    format = v;
                  };
                }
              ];
            }
          ))
          (builtins.attrValues)
        ])
        ++ (lib.pipe config.services.espanso.custom.replace.sequence [
          (builtins.mapAttrs (
            k: v: {
              trigger = k;
              replace = v;
            }
          ))
          (builtins.attrValues)
        ])
        ++ (lib.pipe config.services.espanso.custom.replace.word [
          (builtins.mapAttrs (
            k: v: {
              trigger = k;
              replace = v;
              word = true;
              propagate_case = true;
            }
          ))
          (builtins.attrValues)
        ])
        ++ (lib.pipe config.services.espanso.custom.replace.command [
          (builtins.mapAttrs (
            k: v: {
              trigger = k;
              replace = "{{output}}";
              vars = [
                {
                  name = "output";
                  type = "shell";
                  params = {
                    cmd = writeShellScript "espanso-script" ''
                      export PATH=$PATH:/run/current-system/sw/bin:~/.nix-profile/bin
                      ${v}
                    '';
                  };
                }
              ];
            }
          ))
          (builtins.attrValues)
        ]);
      custom.replace = {
        sequence = {
          ":email:" = "lucas59356@gmail.com";
          ":shrug:" = "¯\\_(ツ)_/¯";
          ":lenny:" = "( ͡° ͜ʖ ͡°)";
          ":fino:" = "🗿🍷";
          # "°" = "\\"; # Alt+E, Alt+Q outputs /
        };
        date = {
          ":hoje:" = "%d/%m/%Y";
        };
        command = {
          ":blaunch:" = "webapp > /dev/null"; # borderless browser
          ":globalip:" = "curl ifconfig.me";
          ":lero:" = "lero"; # https://github.com/lucasew/lerolero.sh
          ":lockscreen:" = "loginctl lock-session 2>&1";
          ":nixinfo:" = "nix-shell -p nix-info --run 'nix-info -m'";
        };
        word = {
          lenght = "length";
          ther = "there";
          automacao = "automação";
          its = "it's";
          dont = "don't";
          didnt = "didn't";
          cant = "can't";
          shouldnt = "shouldn't";
          arent = "aren't";
          youre = "you're";
        };
      };
    };
  };
}
