{lib, stdenv, fetchurl, jdk, callPackage}:
let
  # TODO: Why can't i use rec one level above and be done?
  opencvJava = callPackage ../opencvJava { };
in
stdenv.mkDerivation rec{

  pname = "sikulixIDE";

  version = "2.0.4";

  src = fetchurl {
    url = "https://launchpad.net/sikuli/sikulix/${version}/+download/sikulixide-${version}.jar";
    sha256 = "0pq0d58h4svkgnw3h5qv27bzmap2cgx0pkhmq824nq4rdj9ivphi";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/sikulix-ide.jar
    echo "export LD_LIBRARY_PATH=${opencvJava}/share/java/opencv4/
    ${jdk}/bin/java -jar ${src} \$@
    " > $out/bin/sikulix-ide
    chmod +x $out/bin/sikulix-ide
    mkdir -p $out/share/applications
    echo "[Desktop Entry]
    Version=${version}
    Name=Sikulix-IDE
    Comment=Desktop Automation
    KEywords=automation;script
    Exec=$out/bin/sikulix-ide
    Terminal=false
    Type=Application" > $out/share/applications/sikulix.desktop
  '';

  meta = {
    description = "Automate what you see on a computer monitor";
    homepage = "http://sikulix.com/";
    license = lib.licenses.mit;
    platforms = jdk.meta.platforms;
  };
}
