{ stdenv, custom, zip, fetchurl }:
stdenv.mkDerivation {
  name = "base16-firefox";
  unpackPhase = ''
    substitute ${./base16.js} base16.js --replace "%COLORS%" "$colorsJSON"
    cp ${./manifest.json} manifest.json
    mkdir icons
    cp ${fetchurl { url = "https://github.com/mdn/webextensions-examples/blob/master/borderify/icons/border-48.png"; sha256 = "1w68k4s7lpfns6pisydzkzax45mnc6k1a265pli90zzxwhzwcglv";}} icons/border-48.png
  '';

  nativeBuildInputs = [ zip ];
  installPhase = ''
    mkdir $out
    zip -r $out/nixos@base16.xpi base16.js manifest.json icons
  '';
  colorsJSON = builtins.toJSON custom.colors;
  passthru.extid = "nixos@base16";
}
