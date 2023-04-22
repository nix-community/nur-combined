{ lib
, fetchFromGitHub
, stdenv
, fontforge
, writeText
, useNerdfontsOffset ? true
,
}:
let
  pname = "octicons";
  version = "4.4.0";
  src = fetchFromGitHub {
    owner = "primer";
    repo = "octicons";
    rev = "v${version}";
    sha256 = "sha256-xhJRe5mO2YkqQggqZ1JHBYsJKQUSJA08crDvl22GSGg=";
  };

  script = writeText "octicons.py" ''
    import fontforge
    import json
    import itertools


    if ${
      if useNerdfontsOffset
      then "True"
      else "False"
    }:
      validRange = list(itertools.chain((0x2665, 0x26a1), range(0xF400, 0xF4A8), (0xF112, 0xF67C)))
      def codepointTransform(_):
        return validRange.pop(0)
    else:
      codepointTransform = lambda cp: cp

    offset = ${
      if useNerdfontsOffset
      then "0x0400"
      else "0"
    }

    with open("${src}/lib/font/codepoints.json") as f:
      codepoints = json.load(f)

    font = fontforge.font()

    for name, codepoint in sorted(codepoints.items(), key=lambda item: item[1]):
      transformed = codepointTransform(codepoint)
      print(name, hex(transformed))
      glyph = font.createChar(transformed)
      glyph.importOutlines(f"${src}/lib/svg/{name}.svg")

    font.familyname = "${pname}"
    font.fullname = "${pname}"
    font.fontname = "${pname}"

    font.generate("${pname}.ttf")
  '';
in
stdenv.mkDerivation rec {
  inherit version src pname;

  buildPhase = ''
    fontforge \
      -lang py \
      -script ${script} \;
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/fonts/truetype
    mv ${pname}.ttf $out/share/fonts/truetype
    echo $out
  '';

  nativeBuildInputs = [ fontforge ];

  meta = with lib; {
    description = "GitHub's Octicons icon pack";
    homepage = "https://github.com/primer/octicons";
    license = licenses.mit;
    maintainers = with maintainers; [ minion3665 ];
  };
}
