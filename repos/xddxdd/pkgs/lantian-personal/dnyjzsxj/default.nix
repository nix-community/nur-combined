{ lib
, stdenv
, fetchurl
, chmlib-utils
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "dnyjzsxj";
  version = "1.0.0";

  src = fetchurl {
    url = "https://backblaze.lantian.pub/file/lantian/dnyjzsxj.chm";
    sha256 = "11svflzscbanly6hgk8gxkdsl9n428apc5z565sdgx0vq9355ash";
  };

  dontUnpack = true;

  installPhase = ''
    ${chmlib-utils}/bin/extract_chmLib ${src} $out/
    rm -rf $out/\#* $out/\$*
    for FILE in $(find $out/ -name \*.html -or -name \*.htm -or -name \*.css -or -name \*.js); do
      echo $FILE
      # Convert charset
      iconv -c -f gbk -t utf-8 $FILE > tmp
      mv tmp $FILE
    done
  '';
}
