{ lib, stdenv, fetchurl, unzip, wine, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "synwrite-bin";
  version = "6.40.2770";

  src = fetchurl {
    url = "mirror://sourceforge/synwrite/Release/SynWrite.${version}.zip";
    sha256 = "0xv6y5n99z6msy16bd1rw3ql0myczjna0yl629msrhhh1yygzbb2";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/synwrite
    cp -r . $out/opt/synwrite

    makeWrapper ${wine}/bin/wine $out/bin/synwrite \
      --run "[ -d \$HOME/.synwrite ] || { cp -r $out/opt/synwrite \$HOME/.synwrite && chmod -R +w \$HOME/.synwrite; }" \
      --add-flags "\$HOME/.synwrite/Syn.exe"
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Advanced text editor for programmers and Notepad replacement";
    homepage = "http://uvviewsoft.com/synwrite/";
    license = licenses.mpl11;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
