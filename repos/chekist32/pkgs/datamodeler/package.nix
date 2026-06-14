{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  rpm,
  jdk17,
  openjfx17,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "datamodeler";
  version = "24.3.1.351.0831-1";

  src = fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/datamodeler-${finalAttrs.version}.noarch.rpm";
    sha256 = "0nir5pi4n0xwcdrwkjhsbxw6y2ggiwfjznpl5flnkiwslslkhk4r";
  };

  nativeBuildInputs = [
    rpm
    makeWrapper
  ];

  dontBuild = true;

  unpackPhase = ''
    rpm2archive "$src" | tar xz
  '';

  installPhase = ''
    appdir=$(dirname $(find . -name "datamodeler.sh" | head -1))

    mkdir -p "$out/share/datamodeler" "$out/bin"
    cp -r "$appdir"/. "$out/share/datamodeler/"
    chmod +x "$out/share/datamodeler/datamodeler.sh"

    makeWrapper "$out/share/datamodeler/datamodeler.sh" "$out/bin/datamodeler" \
      --set JAVA_HOME "${jdk17}" \
      --set JDK_HOME  "${jdk17}" \
      --set _JAVA_OPTIONS "-Djava.library.path=${openjfx17}/modules_libs/javafx.graphics:${openjfx17}/modules_libs/javafx.media --add-opens=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED -Dpolyglot.engine.WarnInterpreterOnly=false"
  '';

  meta = with lib; {
    description = "Oracle SQL Developer Data Modeler - free data modeling and design tool";
    homepage = "https://www.oracle.com/database/sqldeveloper/technologies/sql-data-modeler";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "datamodeler";
  };
})
