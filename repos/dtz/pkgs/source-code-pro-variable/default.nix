{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "source-code-pro-variable-fonts";
  version = "1.010";

  srcs = [
    (fetchurl { url = https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf;
    sha256 = "1srp3615ckshylqyh9wyd9i1i5d4d7qkd0nab3cwnxpj83npnrzz"; })
    (fetchurl { url = https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf;
    sha256 = "0p0j74ibxlmlrxw30riz8gz0f3879pgbcsm63lc092av94phz8rb"; })
  ];

  buildCommand = ''
    mkdir -p $out/share/fonts/truetype/
    cp -a $srcs $out/share/fonts/truetype/
  '';

  meta = {
    description = "A set of monospaced OpenType fonts designed for coding environments (variable)";
    maintainers = with stdenv.lib.maintainers; [ dtzWill ];
    platforms = with stdenv.lib.platforms; all;
    homepage = https://blog.typekit.com/2012/09/24/source-code-pro/;
    license = stdenv.lib.licenses.ofl;
  };
}
