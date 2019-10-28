{ fetchurl }:

let version = "2.0.0";
in fetchurl {
  name = "nerd-font-symbols-${version}";
  sha256 = "04n5n2ln8q3nl72n0ni3azy718ki75865q0r1bhans9jhyd935f1";
  downloadToTemp = true;
  recursiveHash = true;
  url =
    "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/${version}/src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf";
  postFetch = ''
    mkdir -p $out/share/fonts/nerd-font-symbols
    cp $downloadedFile $out/share/fonts/nerd-font-symbols/Nerd-Font-Symbols.ttf
  '';
}
