{ stdenv, lib, pkgs, fetchurl, jre, makeWrapper, unzip }:
stdenv.mkDerivation rec {
  name = "${packageName}-${version}";
  packageName = "jd-gui";
  version  = "1.4.0";

  src = fetchurl {
    url = "https://github.com/java-decompiler/jd-gui/releases/download/v${version}/${name}.jar";
    sha256 = "0rvbplkhafb6s9aiwgcq4ffz4bvzyp7q511pd46hx4ahhzfg7lmx";
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  phases = [ "installPhase" ];

  installPhase = ''
    f=$out/lib/jd-gui/
    bin=$out/bin
    name=$(basename $src)
    mkdir -p $f $bin

    # fixup path to java
    cp $src $f
    cat > $bin/jd-gui <<EOF
    #!/bin/sh
    exec ${pkgs.jre}/bin/java -jar $f/$name \$@
    EOF
    chmod +x $bin/jd-gui
  '';

  meta = {
    homepage = https://github.com/java-decompiler/jd-gui;
    description = "A standalone Java Decompiler GUI";
    license = lib.licenses.gpl3;
  };
}
