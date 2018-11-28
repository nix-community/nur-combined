{ stdenv, fetchzip, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "yComp";
  version = "1.3.19";
  name="${pname}-${version}";

  src = fetchzip {
    url = "http://pp.ipd.kit.edu/firm/download/${name}.zip";
    sha256 = "0aakjacc0cb3mz1vnk2bxi8b5qz32rnj9imb3ycgwjsk5rmwxmr0";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/ycomp

    mv *.jar $out/share/ycomp/

    makeWrapper ${jre}/bin/java $out/bin/ycomp \
      --add-flags "-cp $out/share/ycomp" \
      --add-flags "-jar $out/share/ycomp/yComp.jar"
  '';

  meta = with stdenv.lib; {
    description = "Visualization tool for program dependency graphs in VCG format";
    homepage = https://pp.ipd.kit.edu/firm/yComp.html;
    license = licenses.unfree; # Not quite, but playing it safe for now.
    maintainers = with maintainers; [ dtzWill ];
  };
}
