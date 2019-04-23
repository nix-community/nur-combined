{ }:

let

inherit (builtins) elemAt isFunction isString match substring;
identity = x: x;
strHead = substring 0 1;
strRest = substring 1 (-1);
# utf8 = import ../utf8;

# edn resources:
# official edn spec: https://github.com/edn-format/edn
# proposed formal syntax: https://github.com/edn-format/edn/issues/56
# newlines end comments: https://github.com/edn-format/edn/issues/31
# \formfeed is intentionally omitted:
#   https://github.com/edn-format/edn/issues/55
#   (we naturally extend this to \backspace because lol Unicode in Nix)
#
# Nix resources:
# strings can't contain NUL: https://github.com/NixOS/nix/issues/1307
# std::regex::extended is inconsistent across platforms:
#   https://github.com/NixOS/nix/issues/1537
# std::regex doesn't like large strings:
#   https://github.com/NixOS/nix/issues/2147
#   (also PCRE consideration)
# std::regex::ECMAScript consideration:
#   https://github.com/NixOS/nix/issues/1520
# unlikely Earley consideration: https://github.com/NixOS/nix/issues/1491
# lol Unicode:
#   UTF-8 support (closed): https://github.com/NixOS/nix/issues/770
#   fromJSON & Hydra: https://github.com/NixOS/nix/issues/2257
#   overlay paths: https://github.com/NixOS/nix/issues/2610

cSpace = " "; # \space
cCharacterTabulation = "\t"; # builtins.fromJSON ''"\u0009"'';
cTab = "\t"; # \tab
cLineFeed = "\n"; # builtins.fromJSON ''"\u000A"'';
cNewline = "\n"; # (platform-dependent) \newline
cCarriageReturn = "\r"; # builtins.fromJSON ''"\u000D"'';
cReturn = "\n"; # (platform-dependent) \return
whitespace = "${cSpace}${cCharacterTabulation}${cLineFeed}${cCarriageReturn},";
wsClass = "[" + whitespace + "]";

# basic parsing: left space, value, ? right space, ? comment, ? repeat
leftWsPat = "(${wsClass}*)(.*)";
matchLeftWs = match leftWsPat;
rightWsPat = "(${wsClass}*)(;.*)?";
matchRightWs = match rightWsPat;
commentPat = ";([^${cNewline}]*)${cNewline}?(.*)";
matchComment = match commentPat;

literal = {
  # \\backspace = ;
  # \\formfeed = ;
  "\\newline" = cNewline;
  "\\return" = cReturn;
  "\\space" = cSpace;
  "\\tab" = cTab;
  false = false;
  nil = null;
  true = true;
};

parseLosslessGo = f: s: let
  leftWsGroups = matchLeftWs s;
  leadingWs = elemAt leftWsGroups 0;
  elStr = elemAt leftWsGroups 1;

  el = literal.${elStr} or
  (if strHead elStr == "\\" then
    "wut"
  else throw "bad edn parse");
in f []; # [ leadingWs elStr trailingWs comment ];

parseLossless' = f: assert isFunction f; s: assert isString s;
  parseLosslessGo f s;

parseLossless = s: assert isString s;
  parseLosslessGo identity s;

emitLosslessGo = f: e: null;
emitLossless' = f: assert isFunction f; e: emitLosslessGo f e;
emitLossless = e: emitLosslessGo identity e;

in { inherit parseLossless' parseLossless emitLossless' emitLossless; }
