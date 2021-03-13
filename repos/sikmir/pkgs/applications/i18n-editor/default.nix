{ lib, stdenv, fetchfromgh, unzip, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "i18n-editor-bin";
  version = "2.0.0-beta.1";

  src = fetchfromgh {
    owner = "jcbvm";
    repo = "i18n-editor";
    name = "i18n-editor-${version}.zip";
    sha256 = "19p9p6h4kfv468frdsl88w4x3z4bnhlcnll21zw63xhccw55v0lj";
    inherit version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  buildInputs = [ jre makeWrapper ];

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 i18n-editor.jar -t $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/i18n-editor \
      --add-flags "-jar $out/share/java/i18n-editor.jar"
  '';

  meta = with lib; {
    description = "GUI for editing your i18n translation files";
    homepage = src.meta.homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = true;
  };
}
