{ imagemagick, runCommandNoCC }:
{ image, name ? "image.png" }:
runCommandNoCC name { } ''
  ${imagemagick}/bin/convert ${image} $out
''
