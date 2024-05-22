{ pkgs, ... }:

let
  nur = import ../../nur.nix { inherit pkgs; };
in
{
  imports = [ nur.hmModules.xcompose ];

  xcompose.sequences = {
    # Spaces
    " " = " 0"; # figure space
    " " = " ,"; # thin space
    " " = " m"; # em space
    " " = " _"; # non-breaking space
    "	" = "  "; # horizontal tab
    "​" = " z"; # zero-width space
    "‌" = " j"; # zero-width non-joiner

    # Punctuation
    "‽" = "!?"; # interrobang
    "′" = "`'"; # prime
    "″" = "`\""; # double prime
    "»" = ">>"; # right double angle quotation mark
    "›" = ">."; # right single angle quotation mark
    "«" = "<<"; # left double angle quotation mark
    "‹" = "<."; # left single angle quotation mark
    "—" = "--"; # em dash
    "–" = "-n"; # en dash
    "­" = "-?"; # soft hyphen
    "‑" = "-_"; # non-breaking hyphen
    "•" = "-."; # bullet
    "°" = "oo"; # degree
    "⋮" = ".|"; # vertical ellipsis
    "·" = ".-"; # middle dot
    "…" = ".."; # horizontal ellipsis

    # Mathematical operators
    "≈" = "~="; # almost equal to
    "≠" = "!="; # not equal to
    "≥" = ">="; # greater-than or equal to
    "≤" = "<="; # less-than or equal to
    "−" = "-0"; # minus sign
    "±" = "+-"; # plus-minus sign
    "√" = "sq"; # square root
    "×" = "xx"; # multiplication sign

    # Geometric symbols
    "↑" = "|^"; # up arrow
    "↓" = "|v"; # down arrow
    "⇒" = "=>"; # right double arrow
    "↔" = "<>"; # left-right arrow
    "←" = "<-"; # left arrow
    "→" = "->"; # right arrow
    "✓" = "//"; # check mark

    # Keyboard keys
    "⇮" = "ag"; # AltGr
    "⎇" = "al"; # Alt
    "⌫" = "ba"; # Backspace
    "⎄" = "com"; # Compose
    "⎈" = "ct"; # Control
    "⌦" = "de"; # Delete
    "⎋" = "es"; # Escape
    "⎙" = "pr"; # Print Screen
    "↵" = "re"; # Return
    "⇧" = "shi"; # Shift
    "❖" = "su"; # Super
    "↹" = "ta"; # Tab

    # Numbers
    "∅" = "0/"; # null sign
    "π" = "pi"; # pi
    "∞" = "88"; # infinity
    "½" = "12"; # one half
    "⅓" = "13"; # one third
    "⅔" = "23"; # two thirds
    "¼" = "14"; # one fourth
    "¾" = "34"; # three fourths
    "⅕" = "15"; # one fifth
    "⅖" = "25"; # two fifths
    "⅗" = "35"; # three fifths
    "⅘" = "45"; # four fifths
    "⅙" = "16"; # one sixth
    "⅚" = "56"; # five sixths
    "⅐" = "17"; # one seventh
    "⅛" = "18"; # one eighth
    "⅜" = "38"; # three eighths
    "⅝" = "58"; # five eighths
    "⅞" = "78"; # seven eighths
    "⅑" = "19"; # one ninth
    "⅒" = "10"; # one tenth

    # Letters and letterlike symbols
    "æ" = "ae"; # ae ligature
    "à" = "a`"; # a with grave
    "¢" = "c|"; # cent sign
    "ↄ" = "c<"; # reversed c
    "©" = "cop"; # copyright sign
    "µ" = "mu"; # micro sign
    "ñ" = "n~"; # n with tilde
    "ø" = "o/"; # o with stroke
    "¶" = "pp"; # pilcrow sign
    "§" = "ss"; # section sign
    "™" = "tm"; # trade mark sign
    "ü" = "u:"; # u with diaeresis
    "ꝟ" = "v/"; # v with stroke

    # Superscript
    "⁻" = "^-"; # superscript minus
    "⁺" = "^+"; # superscript plus sign
    "⁰" = "^0"; # superscript zero
    "¹" = "^1"; # superscript one
    "²" = "^2"; # superscript two
    "³" = "^3"; # superscript three
    "⁴" = "^4"; # superscript four
    "⁵" = "^5"; # superscript five
    "⁶" = "^6"; # superscript six
    "⁷" = "^7"; # superscript seven
    "⁸" = "^8"; # superscript eight
    "⁹" = "^9"; # superscript nine
    "ᵈ" = "^d"; # superscript d
    "ⁿ" = "^n"; # superscript n
    "ʳᵈ" = "^r"; # superscript rd
    "ˢᵗ" = "^s"; # superscript st
    "ᵗʰ" = "^t"; # superscript th

    # Subscript
    "₋" = "_-"; # subscript minus
    "₊" = "_+"; # subscript plus sign
    "₀" = "_0"; # subscript zero
    "₁" = "_1"; # subscript one
    "₂" = "_2"; # subscript two
    "₃" = "_3"; # subscript three
    "₄" = "_4"; # subscript four
    "₅" = "_5"; # subscript five
    "₆" = "_6"; # subscript six
    "₇" = "_7"; # subscript seven
    "₈" = "_8"; # subscript eight
    "₉" = "_9"; # subscript nine

    # Emoji
    "⚠️" = "wa"; # warning sign
    "❌️" = "no"; # cross mark (emoji variation)
    "✅" = "ye"; # white heavy check mark
    "🤷" = "shr"; # shrug
    "🙃" = "(:"; # upside-down face
    "🙄" = "ey"; # face with rolling eyes

    # Snippets
    "https://" = "ht";
  };
}
