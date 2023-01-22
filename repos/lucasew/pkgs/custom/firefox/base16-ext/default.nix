{ stdenv, custom, zip, fetchurl }:
stdenv.mkDerivation {
  name = "base16-firefox";
  unpackPhase = ''
    substitute ${./base16.js} base16.js --replace "%COLORS%" "$colorsJSON"
    cp ${./manifest.json} manifest.json
    mkdir icons
    cp ${fetchurl { url = "https://raw.githubusercontent.com/mdn/webextensions-examples/main/borderify/icons/border-48.png"; sha256 = "sha256-c3clkz319uDlIRI5u7s1AEkzT1W53ILVBkbsjs0fDUg=";}} icons/border-48.png
  '';

  nativeBuildInputs = [ zip ];
  installPhase = ''
    mkdir $out
    zip -r $out/nixos@base16.xpi base16.js manifest.json icons
  '';
  colorsJSON = builtins.toJSON custom.colors;
  passthru.extid = "nixos@base16";
}
