{ stdenv, fetchurl, p7zip, name ? "", fontName ? "", sha256 ? "", ... }:
stdenv.mkDerivation rec {
  inherit name fontName;
  src = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/${name}.dmg";
    inherit sha256;
  };

  nativeBuildInputs = [ p7zip ];
  unpackPhase = "7z x ${src}";

  # https://stackoverflow.com/questions/2657012/how-to-properly-nest-bash-backticks
  # https://stackoverflow.com/questions/9953448/how-to-remove-all-white-spaces-from-a-given-text-file
  buildPhase = ''
    cd $( echo ${fontName} | tr -d "[:space:]" )
    7z x "${fontName}.pkg" && 7z x Payload~ && cd ./Library/Fonts/
  '';

  # https://unix.stackexchange.com/questions/125385/combined-mkdir-and-cd
  installPhase = ''mkdir -p $out/share/fonts/opentype/ && cp * "$_"'';
}
