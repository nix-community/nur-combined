{ stdenv, lib, pkgs, fetchurl, jre, makeWrapper, unzip }:
stdenv.mkDerivation rec {
  name = "${packageName}-${version}";
  packageName = "dex2jar";
  version  = "2.0";

  src = fetchurl {
    url = "mirror://sourceforge/${packageName}/${name}.zip";
    sha256 = "1g3mrbyl8sdw1nhp17z23qbfzqpa0w2yxrywgphvd04jdr6yn1vr";
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  unpackPhase = ''
    unzip $src
    cd ${name}
  '';

  configurePhase = ":";

  buildPhase = ''
    rm *.bat
    chmod +x *.sh
  '';

  installPhase = ''
    f=$out/lib/dex2jar/
    bin=$out/bin

    mkdir -p $f $bin

    # fixup path to java
    sed -i 's#^java#${pkgs.jre}/bin/java#' d2j_invoke.sh

    mv * $f
    for i in $f/*.sh; do
      n=$(basename ''${i%.sh})
      makeWrapper $i $bin/$n
    done
  '';
  fixupPhase = ":";

  meta = {
    homepage = https://sourceforge.net/projects/dex2jar/;
    description = "Tools to work with android .dex and java .class files";
    license = lib.licenses.asl20;
  };
}
