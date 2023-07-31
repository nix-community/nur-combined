{ pkgs, lib, ... }:
let
  pluginRepo = pkgs.fetchFromGitHub {
    owner = "mwittrien";
    repo = "BetterDiscordAddons";
    rev = "e3c39ba99c836f6a8517a23817ae12af6df6dc17"; # 29-07-2023
    hash = "sha256-AYTAhym71wgkvCtL2GRT/FXrtfQEDM264sT6+OQfHrw=";
  };
  betterdiscordPlugins = [
    "BetterFriendList"
    # "CallTimeCounter"
    "CharCounter"
    "CharCounter"
    # "FreeEmojis"
    "SplitLargeMessages"
    "Translator"
    # "WhoReacted"
  ];
in
{
  home.file = {}
  // (builtins.foldl' (x: y: x // { ".config/BetterDiscord/plugins/${y}.plugin.js".source = "${pluginRepo}/Plugins/${y}/${y}.plugin.js"; }) {} betterdiscordPlugins);
  home.activation = {
    betterdiscord = lib.hm.dag.entryAfter ["writeBoundary"] ''
PATH=${lib.makeBinPath (with pkgs; [ curl custom.colorpipe betterdiscordctl ])}:$PATH
BETTERDISCORD_CSS_TEMPLATE=${./custom.css}
${builtins.readFile ./activation.sh}
    '';
  };
}
