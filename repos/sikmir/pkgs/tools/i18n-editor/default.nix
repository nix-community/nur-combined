{ stdenv, fetchzip, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "i18n-editor";
  version = "2.0.0-beta.1";

  src = fetchzip {
    url = "https://github.com/jcbvm/i18n-editor/releases/download/${version}/${pname}-${version}.zip";
    sha256 = "0hkxgmna22qwm72rwaj4l1rxnx1x93z4v843sz58fdfiqmiqjfy3";
    stripRoot = false;
  };

  buildInputs = [ jre makeWrapper ];

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 i18n-editor.jar -t $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/i18n-editor \
      --add-flags "-jar $out/share/java/i18n-editor.jar"
  '';

  meta = with stdenv.lib; {
    description = "GUI for editing your i18n translation files";
    homepage = "https://github.com/jcbvm/i18n-editor";
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
    skip.ci = true;
  };
}
