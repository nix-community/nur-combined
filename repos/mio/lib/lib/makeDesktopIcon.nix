{
  stdenv,
  imagemagick,
}:
{
  name,
  src,
  pathWithinSrc ? "",
  icoIndex ? null, # For dealing with ico files.
}:
let
  escapedName = builtins.replaceStrings [ " " "\n" "\t" ] [ "" "" "" ] name;
in
stdenv.mkDerivation {
  inherit src;
  name = "${escapedName}-icons";

  nativeBuildInputs = [ imagemagick ];
  dontUnpack = if (builtins.stringLength pathWithinSrc) > 0 then false else true;
  srcPath = if (builtins.stringLength pathWithinSrc) > 0 then pathWithinSrc else src;

  installPhase = ''
    ico_index=${builtins.toString icoIndex}

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      mkdir -p $out/hicolor/$size/apps

      if [ "$ico_index" == "" ]
      then
        magick "$srcPath" -resize $size "$out/hicolor/$size/apps/${escapedName}.png"
      else
        magick "$srcPath[$ico_index]" -resize $size "$out/hicolor/$size/apps/${escapedName}.png"
      fi
    done;
  '';
}
