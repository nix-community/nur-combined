{ lib
, stdenv
, libarchive
, p7zip
}:

stdenv.mkDerivation rec {
  pname = "mas";
  version = "1.8.1";

  src = builtins.fetchurl {
    url = "https://github.com/mas-cli/mas/releases/download/v${version}/mas.pkg";
    sha256 = "15fx3id542lnskkjs8qbjf4x175qyrhm8a5kczl96y0kw61j1z2v";
  };

  buildInputs = [ libarchive p7zip ];

  unpackPhase = ''
    #/usr/sbin/pkgutil --expand $src mas_unpacked
    7z x $src
    bsdtar -xf Payload~
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    cp -r ./bin $out
    cp -r ./Frameworks $out
  '';

  postFixup = ''
    install_name_tool -change @rpath/MasKit.framework/Versions/A/MasKit $out/Frameworks/MasKit.framework/Versions/A/MasKit $out/bin/mas
    install_name_tool -change @rpath/Commandant.framework/Commandant $out/Frameworks/MasKit.framework/Versions/A/Frameworks/Commandant.framework/Versions/A/Commandant $out/bin/mas
  '';

  meta = with lib; {
    description = "Mac App Store command line interface";
    homepage = "https://github.com/mas-cli/mas";
    license = licenses.mit;
    maintainers = with maintainers; [ zachcoyle ];
    platforms = platforms.darwin;
  };

}
