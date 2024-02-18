{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    server.enable = false;
    settings = {
      main = {
        font = "Maple Mono SC NF:size=15.5:style=Regular";
        dpi-aware = "yes";
        term = "foot";
        pad = "8x12";
        shell = "${pkgs.fish}/bin/fish";
        login-shell = "no";
      };

      colors = {
        alpha = "0.85";
        background = "35333c";
        bright0 = "a7a8bd";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
      };
      key-bindings = {
        prompt-prev = "Control+Shift+z";
        prompt-next = "Control+Shift+x";
      };
      cursor = { blink = "yes"; };
      mouse = {
        alternate-scroll-mode = "yes";
        hide-when-typing = "yes";
      };

      url = {
        launch = "xdg-open $\{url}";
        label-letters = "sadfjklewcmpgh";
        osc8-underline = "url-mode";
        protocols = "http, https, ftp, ftps, file, gemini, gopher";
        uri-characters = ''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.,~:;/?#@!$&%*+="'()[]'';
      };
    };

  };
}
