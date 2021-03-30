{
  lib,
  stdenv,
  fetchurl,
  openjdk11,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "mars-simulator";
  version = "4.5";

  jar = fetchurl {
    url = "http://courses.missouristate.edu/KenVollmar/mars/MARS_4_5_Aug2014/Mars4_5.jar";
    sha256 = "ac340b676ba2b62246b9df77e62f81ad4447bcfd329ab539716bcd09950b7096";
  };
  buildInputs = [
    openjdk11
    makeWrapper
  ];

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${openjdk11}/bin/java $out/bin/mars-simulator --add-flags "-jar $jar"
  '';

  meta = with lib; {
    description = "MIPS Assembler and Runtime Simulator";
    longDescription = ''
    MARS is a lightweight interactive development environment (IDE) for
    programming in MIPS assembly language, intended for educational-level use
    with Patterson and Hennessy's Computer Organization and Design.
    '';

    homepage = http://courses.missouristate.edu/KenVollmar/mars/index.htm;

    license = licenses.mit;
  };
}
