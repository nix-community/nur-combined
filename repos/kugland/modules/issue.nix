{ lib
, config
, ...
}:
with lib; let
  cfg = config.console.issue;

  esc = builtins.fromJSON ''"\u001b"'';
  csi = "${esc}[";
  osc = "${esc}]";
  st = "${esc}\\";
  si = builtins.fromJSON ''"\u000f"'';
  clear = [ "${csi}3J" "${csi}2J" "${csi}1;1H" ];
  clearLine = "${csi}K";
  attr = s: "${csi}${s}m";
  reset = attr "0";
  bold = attr "1";
  cyan = attr "22;36";
  bri-black = attr "90";
  bri-red = attr "91";
  bri-cyan = attr "96";
  bri-white = attr "97";
  bg-cyan = attr "46";
  bg-white = attr "47";
  lastCol = "${csi}999C";
  moveTo = x: y: "${csi}${toString y};${toString (x + cfg.padding)}H";

  deltaCol = col:
    if col > 0
    then "${csi}${toString col}C"
    else "${csi}${toString (-col)}D";
  rect = bgColor: right: top: height:
    if height > 0
    then
      [
        (moveTo right top)
        bgColor
        clearLine
        lastCol
        (deltaCol (-right - cfg.padding + 2))
        reset
        clearLine
      ]
      ++ (rect bgColor right (top + 1) (height - 1))
    else [ ];
  savePos = "${csi}s";
  restorePos = "${csi}u";

  headerLeft = [ bri-cyan bg-cyan "welcome to " bri-white "\\n" ];
  headerRight = [ bri-cyan bg-cyan "/dev/" bri-white "\\l" ];

  palette =
    let
      intToHex = "0123456789abcdef";
    in
    [ "${osc}R${st}" ]
    ++ (lib.imap0
      (i: c: [
        "${osc}P${lib.substring i 1 intToHex}${c}${st}"
        "${osc}4;${toString i};#${c}${st}"
      ])
      cfg.colors);

  prologue =
    [
      "${esc}c"
      "${csi}0;0r"
      "${esc}(B"
      "${esc})B"
      "${esc}%G"
      si
      "${esc}~"
      "${csi}3l"
      "${csi}4l"
      "${csi}20l"
      "${csi}?1l"
      "${csi}?3l"
      "${csi}?5l"
      "${csi}?6l"
      "${csi}?7h"
      "${csi}?8h"
      "${csi}?9l"
      "${csi}?25h"
      "${csi}?1000l"
      "${csi}1;15]"
      "${csi}2;8]"
      "${csi}0;37m"
      "${csi}8]"
    ]
    ++ palette
    ++ [
      clear
      "${csi}1;1H"
    ];

  netIfacesOffset = b: b + (builtins.length cfg.netIfaces * 3);
  valuesColumn =
    8
    + (
      builtins.elemAt
        (
          lib.sort (a: b: a > b) (map builtins.stringLength cfg.netIfaces)
        )
        0
    );

  issueText = lib.concatStrings (lib.flatten [
    prologue
    [
      (rect bg-cyan 0 3 3)
      (rect bg-white 0 6 (netIfacesOffset 7))
      (rect bg-cyan 0 11 1)
    ]
    [ (moveTo 3 4) headerLeft lastCol (deltaCol (-(cfg.padding + 10))) headerRight ]
    [ (moveTo 5 7) bri-black bg-white "distro" ]
    [ (moveTo valuesColumn 7) cyan "►  " bri-white "\\S" ]
    [ (moveTo 5 9) bri-black "kernel" ]
    [ (moveTo valuesColumn 9) cyan "►  " bri-white "\\r" ]
    (lib.imap0
      (i: iface:
        let
          line = 13 + (i * 3);
        in
        [
          [ (moveTo 5 line) bri-black iface ]
          [ (moveTo valuesColumn line) cyan "►  " ]
          [ savePos cyan "<no ip>" restorePos bri-white "\\4{${iface}}" ]
          [ (moveTo (valuesColumn + 3) (line + 1)) ]
          [ savePos cyan "<no ip>" restorePos bri-white "\\6{${iface}}" ]
        ])
      cfg.netIfaces)
    (moveTo 2 (netIfacesOffset 15))
    [ reset bri-red "☼  " reset "Press " bold bri-white "Alt SysRq K" reset " before logging in." ]
    (moveTo (-cfg.padding) (netIfacesOffset 18))
  ]);
in
{
  options = {
    console.issue = {
      enable = mkEnableOption "Enable the custom issue file";
      padding = mkOption {
        type = types.int;
        default = 16;
        description = "Padding to use for the issue file";
      };
      netIfaces = mkOption {
        type = types.listOf types.str;
        default = lib.uniqueStrings (builtins.filter
          (x: x != null)
          (with config.hostConfig; [
            primaryNetIface
            wirelessNetIface
          ]));
        description = "Network interfaces to show IP addresses for";
      };
      colors = mkOption {
        type = types.listOf types.str;
        default = lib.take 16 config.scheme.toList;
        description = "Console colors to use";
      };
    };
  };
  config = {
    environment.etc.issue = {
      text = lib.mkForce issueText;
      mode = "0444";
    };
  };
}
