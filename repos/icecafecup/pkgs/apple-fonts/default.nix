{ stdenv, lib, wget, p7zip, ... }:

stdenv.mkDerivation rec {
  pname = "apple-fonts";
  version = "0.0.0";
  src = ./.;

  nativeBuildInputs = [ wget p7zip ];

  unpackPhase = ''
    	mkdir -p $out/fontfiles

    	wget http://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg
      7z x SF-Pro.dmg
      cd SFProFonts
      7z x 'SF Pro Fonts.pkg'
      7z x 'Payload~'
      mv Library/Fonts/* $out/fontfiles
      cd ..

      wget http://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg
      7z x SF-Compact.dmg
      cd SFCompactFonts
      7z x 'SF Compact Fonts.pkg'
      7z x 'Payload~'
      mv Library/Fonts/* $out/fontfiles
      cd ..

    	wget http://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg
      7z x SF-Mono.dmg
      cd SFMonoFonts
      7z x 'SF Mono Fonts.pkg'
      7z x 'Payload~'
      mv Library/Fonts/* $out/fontfiles
      cd ..

      wget http://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg
      7z x SF-Arabic.dmg
      cd SFArabicFonts
      7z x 'SF Arabic Fonts.pkg'
      7z x 'Payload~'
      mv Library/Fonts/* $out/fontfiles
      cd ..

      wget http://devimages-cdn.apple.com/design/resources/download/NY.dmg
      7z x NY.dmg
      cd NYFonts
      7z x 'NY Fonts.pkg'
      7z x 'Payload~'
      mv Library/Fonts/* $out/fontfiles
      cd ..
  '';

  installPhase = ''
        mkdir -p $out/share/fonts/truetype
        mkdir -p $out/share/fonts/opentype

        cp -r $out/fontfiles/*.ttf $out/share/fonts/truetype/
        cp -r $out/fontfiles/*.otf $out/share/fonts/opentype
    		rm -rf $out/fontfiles
  '';

  meta = with lib; {
    description = "Apple San Francisco, New York fonts, directly from Apple official source";
    homepage = "https://developer.apple.com/fonts/";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
