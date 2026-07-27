{ stdenv, imagemagick, fetchurl }:

let
  source = fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/10/Blank-Wallpaper-Full-HD.png";
    sha256 = "1z2xg8ffqyg9lp9xhm70asnpiw952waq2l5irj1fydkp5hbbgaxx";
    name = "background-original.jpg";
  };
in

stdenv.mkDerivation rec {
  name = "dotfiles-background";
  src = source;
  buildInputs = [ imagemagick ];
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    convert $src -resize 3840x2160^ shrink-h.png
    convert shrink-h.png -gravity South -crop 3840x2160+0+0 shrink.png
    convert shrink.png -crop 3840x1080+0+990 result-wide.png
    convert shrink.png -resize 1920x1080 result.png
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/${name}
    # Make sure the source does not get garbage collected.
    ln -s $src $out/lib/${name}/${source.name}

    cp result-wide.png $out/lib/${name}/background-wide.png
    cp result.png $out/lib/${name}/background.png

    cat <<EOF > $out/bin/${name}
    #!/bin/sh

    echo $out/lib/${name}/background.png
    EOF
    cat <<EOF > $out/bin/${name}-wide
    #!/bin/sh

    echo $out/lib/${name}/background-wide.png
    EOF

    chmod +x $out/bin/${name}
    chmod +x $out/bin/${name}-wide
  '';
}
