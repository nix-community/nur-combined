{ stdenv, fetchFromGitHub, gnuplot, ruby }:

stdenv.mkDerivation {
  name = "eplot-unstable-2018-09-03";

  src = fetchFromGitHub {
    owner = "chriswolfvision";
    repo = "eplot";
    rev = "77bbe535f08a4377a7d86f11a21a726b06470323";
    sha256 = "0y81dbvzmybv9zgvcfw9kzbn0d5sqs6y2hqzq2klsqchcna4b1dn";
  };

  buildInputs = [ ruby ];

  installPhase = ''
    mkdir -p $out/bin
    cp eplot ec $out/bin/
    chmod +x $out/bin/*

    sed -i -e "s|gnuplot -persist|${gnuplot}/bin/gnuplot -persist|" "$out/bin/eplot"
  '';

  meta = with stdenv.lib; {
    description = "Create plots quickly with gnuplot";
    longDescription = ''
      eplot ("easy gnuplot") is a ruby script which allows to pipe data easily
      through gnuplot and create plots quickly, which can be saved in
      postscript, PDF, PNG or EMF files. Plotting of multiple files into a
      single diagram is supported.

      This package also includes the complementary 'ec' tool (say "extract
      column").
    '';
    homepage = http://liris.cnrs.fr/christian.wolf/software/eplot/;
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
